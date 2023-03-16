//VPC

resource "aws_vpc" "assignment3" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "assignment3-vpc"
  }
}


//Public_Subnet

resource "aws_subnet" "public_subnet" {
  count = length(var.available_zones)

  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = var.available_zones[count.index]
  vpc_id            = aws_vpc.assignment3.id

  tags = {
    Name = "assignment3-public-subnet-${count.index}"
  }


}


// Private_Subnet

resource "aws_subnet" "private_subnet" {
  count = length(var.available_zones)

  cidr_block        = "10.0.${count.index + 3}.0/24"
  availability_zone = var.available_zones[count.index]
  vpc_id            = aws_vpc.assignment3.id

  tags = {
    Name = "assignment3-private-subnet-${count.index}"
  }

}



//Internet_Gateway

resource "aws_internet_gateway" "assignment3_gateway" {
  vpc_id = aws_vpc.assignment3.id

  tags = {
    Name = "assignment3-gateway"
  }

}




//Public_Route_Table  &&   Public_ROUTE(0.0.0.0/0)

resource "aws_route_table" "assignment3_public" {
  vpc_id = aws_vpc.assignment3.id

  tags = {
    Name = "assignment3-public-route-table"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.assignment3_gateway.id
  }

}

resource "aws_route_table_association" "assignment3_public_subnet_association" {
  count = length(aws_subnet.public_subnet)

  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.assignment3_public.id

}




// Private_Route_Table

resource "aws_route_table" "assignment3_private" {
  vpc_id = aws_vpc.assignment3.id

  tags = {
    Name = "assignment3-private-route-table"
  }

}


resource "aws_route_table_association" "assignment3_private_subnet_association" {
  count = length(aws_subnet.private_subnet)

  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.assignment3_private.id
}



resource "aws_security_group" "assignment_app" {
  name   = "assignment-app"
  vpc_id = aws_vpc.assignment3.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = "3306"
    to_port     = "3306"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "assignment-app-sg"
  }
}


resource "aws_security_group" "database" {
  name   = "database"
  vpc_id = aws_vpc.assignment3.id

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    # cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.assignment_app.id]
  }


  tags = {
    Name = "database-security-group"
  }
}



resource "random_id" "bucket_name" {
  byte_length = 8
}

resource "aws_s3_bucket" "private_bucket" {
  bucket = "my-bucket-${random_id.bucket_name.hex}"


  force_destroy = true

}

resource "aws_s3_bucket_acl" "private_bucket" {
  bucket = aws_s3_bucket.private_bucket.id
  acl    = "private"

}

resource "aws_s3_bucket_server_side_encryption_configuration" "private_bucket" {
  bucket = aws_s3_bucket.private_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "private_bucket" {
  bucket = aws_s3_bucket.private_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "private_bucket" {
  bucket = aws_s3_bucket.private_bucket.id

  rule {
    id     = "transition-to-standard-ia"
    status = "Enabled"
    filter {
      prefix = ""
    }
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}
resource "aws_s3_bucket_public_access_block" "private_bucket" {
  bucket = aws_s3_bucket.private_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}




resource "aws_db_subnet_group" "assignment" {
  name        = "csye6225-db-subnet-group"
  subnet_ids  = aws_subnet.private_subnet.*.id
  description = "Subnet group for csye6225 RDS instance"

  tags = {
    Name = "csye6225-db-subnet-group"
  }
}




resource "aws_db_parameter_group" "parameter" {
  name_prefix = "assigment-"

  family = "mysql8.0"

}








resource "aws_db_instance" "rds_instance" {
  engine                    = "mysql"
  engine_version            = "8.0"
  instance_class            = "db.t3.micro"
  multi_az                  = false
  identifier                = var.name
  username                  = var.name
  password                  = var.password
  db_subnet_group_name      = aws_db_subnet_group.assignment.name
  publicly_accessible       = false
  db_name                   = var.name
  allocated_storage         = 20
  skip_final_snapshot       = true
  final_snapshot_identifier = "my-final-snapshot"


  vpc_security_group_ids = [aws_security_group.database.id]


  tags = {
    Name = "csye6225-db-instance"
  }
}






resource "aws_iam_role" "ec2_role" {
  name = "EC2-CSYE6225"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

data "aws_iam_policy_document" "webapp_s3_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.private_bucket.id}",
      "arn:aws:s3:::${aws_s3_bucket.private_bucket.id}/*"
    ]
  }
}

resource "aws_iam_policy" "webapp_s3" {
  name   = "WebAppS3"
  policy = data.aws_iam_policy_document.webapp_s3_policy.json
}

resource "aws_iam_role_policy_attachment" "s3_bucket_policy_attachment" {
  policy_arn = aws_iam_policy.webapp_s3.arn
  role       = aws_iam_role.ec2_role.name
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}


data "template_file" "init_instance" {
  template = file(join("", [path.module, "/userData.tpl"]))
  vars = {
    db_hostname        = aws_db_instance.rds_instance.address,
    db_username        = aws_db_instance.rds_instance.username
    db_password        = aws_db_instance.rds_instance.password
    db_endpoint        = aws_db_instance.rds_instance.endpoint
    bucket_name        = aws_s3_bucket.private_bucket.bucket
    db_name            = aws_db_instance.rds_instance.db_name
    aws_key            = var.AWS_KEY
    aws_id             = var.AWS_ID
    aws_default_region = var.region

  }
}


resource "aws_eip" "eip" {
  instance = aws_instance.assignment.id
  vpc      = var.aws_eip_vpc
}

resource "aws_route53_record" "route53_record" {
  zone_id = var.route53_record_zone_id 
  name    = var.route53_record_name 
  type    = var.route53_record_type 
  ttl     = var.route53_record_ttl 
  records = [aws_eip.eip.public_ip]
 }


resource "aws_instance" "assignment" {
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  key_name                    = "ec2"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.assignment_app.id, aws_security_group.database.id]
  subnet_id                   = aws_subnet.public_subnet[0].id
  disable_api_termination     = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name


  root_block_device {
    volume_size           = 50
    volume_type           = "gp2"
    delete_on_termination = true
  }
  user_data = data.template_file.init_instance.rendered
  tags = {
    Name = "assignment-instance"
  }
}





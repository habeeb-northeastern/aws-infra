//VPC

resource "aws_vpc" "myVPC" {
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
  vpc_id            = aws_vpc.myVPC.id

  tags = {
    Name = "assignment3-public-subnet-${count.index}"
  }


}


// Private_Subnet

resource "aws_subnet" "private_subnet" {
  count = length(var.available_zones)

  cidr_block        = "10.0.${count.index + 3}.0/24"
  availability_zone = var.available_zones[count.index]
  vpc_id            = aws_vpc.myVPC.id

  tags = {
    Name = "assignment3-private-subnet-${count.index}"
  }

}



//Internet_Gateway

resource "aws_internet_gateway" "assignment3_gateway" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "assignment3-gateway"
  }

}




//Public_Route_Table  &&   Public_ROUTE(0.0.0.0/0)

resource "aws_route_table" "assignment3_public" {
  vpc_id = aws_vpc.myVPC.id

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
  vpc_id = aws_vpc.myVPC.id

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
  vpc_id = aws_vpc.myVPC.id

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
  vpc_id = aws_vpc.myVPC.id

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

resource "aws_security_group" "lb_sg" {
  name        = "loadbalancer_sg"
  description = "Load Balancer Security Group"
  vpc_id      = aws_vpc.myVPC.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #   description = "NodeJs"
  #   from_port   = 8080
  #   to_port     = 8080
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]

  # }

  egress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lb_security_group"
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

resource "aws_lb" "application_lb" {
  count              = length(aws_subnet.public_subnet)
  name               = "csye6225-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_security_group.id]
  subnets            = aws_subnet.public_subnet[count.index].id

  enable_deletion_protection = false

  tags = {
    Name = "EC2-LoadBalancer"
  }
}

resource "aws_lb_target_group" "lb_target_group" {
  name     = "csye6225-lb-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.myVPC.id
  health_check {
    port    = "8080"
    path    = "/"
    matcher = "200"
  }
}

resource "aws_launch_configuration" "asg_launch_conf" {
  name_prefix                 = "asg_launch_config"
  image_id                    = var.ami_id
  instance_type               = "t2.micro"
  key_name                    = "ec2"
  associate_public_ip_address = true
  user_data                   = data.template_file.init_instance.rendered
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  security_groups             = [aws_security_group.assignment_app.id]
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 50
    delete_on_termination = true
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "csye6225_asg" {
  name                 = "csye6225_asg"
  vpc_zone_identifier  = [aws_subnet.subnet_tf_1.id, aws_subnet.subnet_tf_2.id, aws_subnet.subnet_tf_3.id]
  launch_configuration = aws_launch_configuration.asg_launch_conf.name
  default_cooldown     = 60
  desired_capacity     = 1
  min_size             = 1
  max_size             = 3
  target_group_arns    = [aws_lb_target_group.lb_target_group.arn]
  tag {
    key                 = "Name"
    value               = "assignment"
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "AppScaleUpPolicy" {
  name                   = "AppScaleUpPolicy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.csye6225_asg.name
}

resource "aws_autoscaling_policy" "AppScaleDownPolicy" {
  name                   = "AppScaleDownPolicy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.csye6225_asg.name
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

resource "aws_iam_role_policy_attachment" "cloudwatch_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
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

resource "aws_eip" "eip" {
  instance = aws_instance.assignment.id
  vpc      = true
}

resource "aws_route53_record" "route53_record" {
  zone_id = var.record_zone_id
  name    = var.record_name
  type    = "A"
  ttl     = 300
  records = [aws_eip.eip.public_ip]
  alias {
    name                   = aws_lb.application_lb.dns_name
    zone_id                = aws_lb.application_lb.zone_id
    evaluate_target_health = true
  }
}

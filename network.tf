resource "aws_vpc" "myVPC" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "myVPC"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "private" {
  count                   = var.no_of_pri_subnets
  vpc_id                  = aws_vpc.myVPC.id
  cidr_block              = var.private_subnet[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
}

resource "aws_subnet" "public" {
  count                   = var.no_of_pub_subnets
  vpc_id                  = aws_vpc.myVPC.id
  cidr_block              = var.public_subnet[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
}

resource "aws_security_group" "app_sg" {
  name   = "app_sg"
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
}

resource "aws_instance" "app_instance" {
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  subnet_id                   = element(aws_subnet.public.*.id, 0)
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = true
  key_name                    = "ec2"
  disable_api_termination     = false
  root_block_device {
    volume_size           = 50
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name = "App-instance"
  }
}

resource "aws_db_security_group" "rdss_sg" {
  name = "rds_sg"

  ingress {
    from_port           = 3306
    to_port             = 3306
    security_group_name = "aws_security_group.app_sg"
  }
}

resource "aws_s3_bucket" "bucket" {

  lifecycle_rule {
    id      = "log"
    enabled = true
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }

  force_destroy = true

  server_side_encryption_configuration {
    bucket_key_enabled = true
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }
}

resource "aws_db_parameter_group" "rds_pg" {
  name   = "rds-pg"
  family = "mysql5.6"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}


resource "aws_db_instance" "rds_instance" {
  allocated_storage    = 10
  db_name              = "csye6225"
  identifier           = "csye6225"
  engine               = "mysql"
  instance_class       = "db.t3.micro"
  username             = "csye6225"
  password             = "habeebRDS"
  db_subnet_group_name = "db_pri_subnet"
  parameter_group_name = "rds_pg"
  multi_az             = false
}

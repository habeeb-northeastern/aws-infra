resource "aws_vpc" "myVPC" {
  cidr_block = var.vpc_cidr
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
    from_port = 22
    to_port   = 22
    protocol  = "ssh"
  }
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
  }
  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
  }
}

resource "aws_instance" "app_instance" {
  ami                         = "ami-00e474248335df973" # ca-central-1
  instance_type               = "t2.micro"
  subnet_id                   = element(aws_subnet.public.*.id, 0)
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = true
  disable_api_termination     = false
  root_block_device {
    volume_size = 50
    volume_type = "gp2"
  }
}


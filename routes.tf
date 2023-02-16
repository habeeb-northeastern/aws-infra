resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.myVPC.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.myVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public_rt"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "private_rt"
  }
}

resource "aws_route_table_association" "pub_rta" {
  count          = var.no_of_pub_subnets
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "pri_rta" {
  count          = var.no_of_pri_subnets
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private_rt.id
}

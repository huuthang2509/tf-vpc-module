resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = "my-vpc"
  }
}

resource "aws_subnet" "private_subnets" {
  count = length(var.private_subnets)
  
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = var.private_subnets[count.index]
  availability_zone = var.availability_zone[count.index % length(var.availability_zone)]

  tags = {
    Name = "private-subnets"
  }
}

resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnets)
  
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = var.public_subnets[count.index]
  availability_zone = var.availability_zone[count.index % length(var.availability_zone)]

  tags = {
    Name = "public-subnets"
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "internet-gateway"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }

  tags = {
    Name = "public"
  }
}

resource "aws_route_table_association" "public_association" {
  for_each = { for k,v in aws_subnet.public_subnets : k => v }
  subnet_id = each.value.id
  # count = length(aws_subnet.public_subnets)
  # subnet_id = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat_public" {
  depends_on = [aws_internet_gateway.ig]

  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnets[0].id

  tags = {
    Name = "Public NAT"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_public.id
  }

  tags = {
    "Name" = "private"
  }
}

resource "aws_route_table_association" "public_private" {
  for_each       = { for k, v in aws_subnet.private_subnets : k => v }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt.id
}
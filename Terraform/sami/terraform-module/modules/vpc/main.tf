terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

######################### VPC #########################

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr_block
  instance_tenancy = "default"
#   enable_dns_support = true
#   enable_dns_hostnames = true
  tags = {
    Name = var.name
  }
}

######################### Public SubNet #########################
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr_blocks)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidr_blocks[count.index]
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

######################### Private SubNet #########################
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidr_blocks)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_subnet_cidr_blocks[count.index]
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

######################### IGW #########################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "igw"
  }
}

######################### Public RouteTable #########################
resource "aws_route_table" "public-routetable" {

  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-routetable"
  }
}

######################### SubNet Association Public-RT #########################
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public-routetable.id
}

######################## Private RouteTable #########################
resource "aws_route_table" "private-routetable" {
  
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "Private-routetable"
  }
}
resource "aws_route" "pub_nat_gw" {
  route_table_id = aws_route_table.private-routetable.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.nat[0].id
  count = var.create_nat ? 1 : 0
}
######################### SubNet Association Private-RT #########################
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private-routetable.id
}

######################### EIP #########################
resource "aws_eip" "eip" {
  count = var.create_eip ? 1 : 0
  tags = {
    Name = "EIP-${var.name}"
  }
}

######################### NAT #########################
resource "aws_nat_gateway" "nat" {
  count = var.create_nat ? 1 : 0
  allocation_id = aws_eip.eip[count.index].id
  subnet_id = aws_subnet.public[1].id
  tags = {
    Name = "NAT-${var.name}"
  }
  depends_on = [ aws_eip.eip, aws_internet_gateway.igw ]
}
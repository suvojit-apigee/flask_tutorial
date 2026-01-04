locals {
  availability_zones = ["us-east-1a", "us-east-1b"]

  ingress_rules = [
    {
      description = "SSH"
      port        = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "HTTP"
      port        = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "HTTPS"
      port        = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

resource "aws_vpc" "stellar_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "stellar_vpc"
  }
}

resource "aws_subnet" "stellar_subnet1" {
    vpc_id            = aws_vpc.stellar_vpc.id
    cidr_block        = "10.0.1.0/24"
    availability_zone = local.availability_zones[0]

    tags = {
      Name = "stellar_subnet1"
    } 
}

resource "aws_subnet" "stellar_subnet2" {
    vpc_id            = aws_vpc.stellar_vpc.id
    cidr_block        = "10.0.2.0/24"
    availability_zone = local.availability_zones[1]

    tags = {
      Name = "stellar_subnet2"
    }
}

resource "aws_internet_gateway" "stellar_internert_gateway" {
  vpc_id = aws_vpc.stellar_vpc.id
  
  tags = {
    Name = "stellar_internet_gateway"
  }
}

resource "aws_route_table" "stellar_rt" {
  vpc_id = aws_vpc.stellar_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.stellar_internert_gateway.id
  }

  tags = {
    Name = "stellar_route_table"
  }
}

resource "aws_route_table_association" "stellar_rta1" {
  subnet_id      = aws_subnet.stellar_subnet1.id
  route_table_id = aws_route_table.stellar_rt.id
}

resource "aws_route_table_association" "stellar_rta2" {
  subnet_id      = aws_subnet.stellar_subnet2.id
  route_table_id = aws_route_table.stellar_rt.id
}

resource "aws_security_group" "stellar_sg" {
  name        = "stellar_sg"
  description = "Security group for Stellar VPC"
  vpc_id      = aws_vpc.stellar_vpc.id

  dynamic "ingress" {
    for_each = local.ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "stellar_security_group"
  }
}
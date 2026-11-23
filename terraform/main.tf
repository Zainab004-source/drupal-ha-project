terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Main VPC
resource "aws_vpc" "drupal_vpc" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "Drupal-HA-VPC"
    Project = "Drupal-HA"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "drupal_igw" {
  vpc_id = aws_vpc.drupal_vpc.id

  tags = {
    Name = "Drupal-Internet-Gateway"
  }
}

# Public subnets
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.drupal_vpc.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Drupal-Public-A"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.drupal_vpc.id
  cidr_block              = "10.20.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Drupal-Public-B"
  }
}

# Private database subnets
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.drupal_vpc.id
  cidr_block        = "10.20.11.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Drupal-Private-A"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.drupal_vpc.id
  cidr_block        = "10.20.12.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Drupal-Private-B"
  }
}

# Public route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.drupal_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.drupal_igw.id
  }

  tags = {
    Name = "Drupal-Public-Route-Table"
  }
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

# Private route table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.drupal_vpc.id

  tags = {
    Name = "Drupal-Private-Route-Table"
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_rt.id
}

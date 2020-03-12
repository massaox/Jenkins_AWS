# Master and Workers will reside on the same VPC
resource "aws_vpc" "jenkins-vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    Name = "jenkins-vpc"
  }
}

# Subnets
resource "aws_subnet" "jenkins-public-1" {
  vpc_id                  = aws_vpc.jenkins-vpc.id
  cidr_block              = "10.0.5.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-west-2a"

  tags = {
    Name = "jenkins-public-1"
  }
}

# Subnets
resource "aws_subnet" "jenkins-public-2" {
  vpc_id                  = aws_vpc.jenkins-vpc.id
  cidr_block              = "10.0.6.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-west-2b"

  tags = {
    Name = "jenkins-public-2"
  }
}


## 2 Private subnet for HA
resource "aws_subnet" "jenkins-private-1" {
  vpc_id                  = aws_vpc.jenkins-vpc.id
  cidr_block              = "10.0.7.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "eu-west-2a"

  tags = {
    Name = "jenkins-private-1"
  }
}

resource "aws_subnet" "jenkins-private-2" {
  vpc_id                  = aws_vpc.jenkins-vpc.id
  cidr_block              = "10.0.8.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "eu-west-2b"

  tags = {
    Name = "jenkins-private-2"
  }
}

# Internet GW

resource "aws_internet_gateway" "jenkins-gw" {
  vpc_id = aws_vpc.jenkins-vpc.id

  tags = {
    Name = "jenkins-vpc"
  }
}

# Route table to give SSH access for troubleshooting. 

resource "aws_route_table" "jenkins-public-route" {
  vpc_id = aws_vpc.jenkins-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jenkins-gw.id
  }

  tags = {
    Name = "jenkins-public"
  }
}

# Now linking the route table above with jenkins-vpc

resource "aws_route_table_association" "jenkins-public-1-a" {
  subnet_id      = aws_subnet.jenkins-public-1.id
  route_table_id = aws_route_table.jenkins-public-route.id
}

resource "aws_route_table_association" "main-public-2-a" {
  subnet_id      = aws_subnet.jenkins-public-2.id
  route_table_id = aws_route_table.jenkins-public-route.id
}

# NAT gw for workers to be able to bootstrap

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.jenkins-public-1.id
  depends_on    = [aws_internet_gateway.jenkins-gw]
}

## Setup for NAT
resource "aws_route_table" "jenkins-private-route" {
  vpc_id = aws_vpc.jenkins-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }

  tags = {
    Name = "jenkins-private-1"
  }
}

# route associations private
resource "aws_route_table_association" "jenkins-private-1-a" {
  subnet_id      = aws_subnet.jenkins-private-1.id
  route_table_id = aws_route_table.jenkins-private-route.id
}

resource "aws_route_table_association" "jenkins-private-2-a" {
  subnet_id      = aws_subnet.jenkins-private-2.id
  route_table_id = aws_route_table.jenkins-private-route.id
}


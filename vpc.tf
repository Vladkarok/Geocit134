data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags = {
    Name = "Geocitizen-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Geocitizen-igw"
  }
}


resource "aws_subnet" "public_subnets" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "Geocitizen public subnet"
  }
}


resource "aws_route_table" "public_subnets" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = var.all_cidr_block
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "Geocitizen-route-public-subnets"
  }
}

resource "aws_route_table_association" "public_routes" {
  route_table_id = aws_route_table.public_subnets.id
  subnet_id      = aws_subnet.public_subnets.id
}

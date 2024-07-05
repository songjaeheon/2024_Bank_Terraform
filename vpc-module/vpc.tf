# provider "aws" {
#   region = var.region
# }

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.tag_prefix}_vpc"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public_1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[0] // var.region + "a"

  tags = {
    Name = "${var.tag_prefix}_public_subnet_1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[2] // var.region + "c"

  tags = {
    Name = "${var.tag_prefix}_public_subnet_2"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.4.0/23"
  availability_zone = data.aws_availability_zones.available.names[0] // var.region + "a"

  tags = {
    Name = "${var.tag_prefix}_private_subnet_1"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.6.0/23"
  availability_zone = data.aws_availability_zones.available.names[2] // var.region + "c"

  tags = {
    Name = "${var.tag_prefix}_private_subnet_2"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.tag_prefix}_igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.tag_prefix}_public_rt"
  }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_nat_gateway" "nat_1" {
  allocation_id = aws_eip.nat_1.id
  subnet_id     = aws_subnet.public_1.id

  tags = {
    Name = "${var.tag_prefix}_nat_1"
  }
}

resource "aws_nat_gateway" "nat_2" {
  allocation_id = aws_eip.nat_2.id
  subnet_id     = aws_subnet.public_2.id

  tags = {
    Name = "${var.tag_prefix}_nat_2"
  }
}

resource "aws_eip" "nat_1" {
  # vpc = true // deprecated
  domain = "vpc"
}

resource "aws_eip" "nat_2" {
  # vpc = true // deprecated
  domain = "vpc"
}

resource "aws_route_table" "private_1" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.tag_prefix}_private_rt_1"
  }
}

resource "aws_route_table" "private_2" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.tag_prefix}_private_rt_2"
  }
}

resource "aws_route" "private_nat_1" {
  route_table_id         = aws_route_table.private_1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_1.id
}

resource "aws_route" "private_nat_2" {
  route_table_id         = aws_route_table.private_2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_2.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_1.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_2.id
}

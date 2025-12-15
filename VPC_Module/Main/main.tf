provider "aws" {
    region = var.region
  
}

resource "aws_vpc" "my_vpc" {
    cidr_block = var.vpc_cidr
    instance_tenancy = var.tenancy

    tags = {
      Name = "my-vpc"
      env = "dev"

    }
  
}

resource "aws_internet_gateway" "my-igw" {
    vpc_id = aws_vpc.my_vpc.id

    tags = {
      Name = "my-igw"
      env = "dev"
    }
     
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = var.cidr_subnet
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true

    tags = {
        Name = "public-subnet"
      env = "dev"
      
    }
  
}

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.my_vpc.id
    
    tags = {
        Name = "public-rt"
      env = "dev"
      
    }
  
}

resource "aws_route_table_association" "add_subnet" {
    route_table_id = aws_route_table.public_rt.id
    subnet_id = aws_subnet.public_subnet.id
  
}

resource "aws_route" "my_route" {
    route_table_id = aws_route_table.public_rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  
}
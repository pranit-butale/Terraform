provider "aws" {
  region = "us-east-1"
}

#VPC Creation Block

resource "aws_vpc" "my_vpc" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"

    tags = {
      env = "dev"
      name = "my_tf_vpc"
    }
  
}

#Public Subnet

resource "aws_subnet" "my_public" {
    vpc_id = aws_vpc.my_vpc.id 
    cidr_block = "10.0.0.0/17"
    
    tags = {
      env = "dev"
      name = "tf_ps"
    }
  
}


#Private Subnet

resource "aws_subnet" "my_private" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.128.0/17"
  tags = {
    env = "dev"
    name = "tf_privatesubnet"
  }
}

#Internet Gateway

resource "aws_internet_gateway" "my-igw" {
    vpc_id = aws_vpc.my_vpc.id

    tags = {
      env = "dev"
      name = "tf_igw"
    }
  
}

#Public Route Table

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.my_vpc.id

    tags = {
      env = "dev"
      name = "public_rt"
    }
  
}
#Add Route to Internet

resource "aws_route" "public_route" {
    route_table_id = aws_route_table.public_rt.id 
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  
}

# Route Table Association

resource "aws_route_table_association" "public_association" {
    subnet_id = aws_subnet.my_public.id 
    route_table_id = aws_route_table.public_rt.id
  
}



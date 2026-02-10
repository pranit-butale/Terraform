provider "aws" {
    region = "us-east-1"
  
}

# DEFAULT VPC
data "aws_vpc" "default" {
  default = true
}

# Fetch subnets from default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Subnet Group for RDS
resource "aws_db_subnet_group" "default_rds_subnet" {
  name       = "default-rds-subnet-group"
  subnet_ids = data.aws_subnets.default.ids

  
}

# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds-default-vpc-sg"
  description = "Allow MariaDB access"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS MariaDB
resource "aws_db_instance" "my_rds" {
  identifier             = "my-mariadb-rds"
  engine                 = "mariadb"
  engine_version         = "10.6"

  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"

  db_name                = "mydatabase"
  username               = "admin"
  password               = "Pranit1028"

  db_subnet_group_name   = aws_db_subnet_group.default_rds_subnet.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  publicly_accessible    = false
  skip_final_snapshot    = true
  deletion_protection    = false

  
}

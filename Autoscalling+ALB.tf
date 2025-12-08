###############################################
# PROVIDER CONFIGURATION
###############################################

provider "aws" {
  region = "us-east-1"
}

########################################################
# VPC + SUBNETS + INTERNET GATEWAY + ROUTES
########################################################

# ---------------------
# VPC
# ---------------------
resource "aws_vpc" "my_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    env  = "dev"
    name = "my_tf_vpc"
  }
}

# ---------------------
# Public Subnet 1
# ---------------------
resource "aws_subnet" "my_public" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.0.0/17"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    env  = "dev"
    name = "tf_ps"
  }
}

# ---------------------
# Public Subnet 2
# ---------------------
resource "aws_subnet" "my_public2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.128.0/17"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    env  = "dev"
    name = "tf_ps2"
  }
}

# ---------------------
# Internet Gateway
# ---------------------
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    env  = "dev"
    name = "tf_igw"
  }
}

# ---------------------
# Public Route Table
# ---------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    env  = "dev"
    name = "public_rt"
  }
}

# ---------------------
# Route 0.0.0.0/0 → IGW
# ---------------------
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

# ---------------------
# Route Associations
# ---------------------
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.my_public.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_association2" {
  subnet_id      = aws_subnet.my_public2.id
  route_table_id = aws_route_table.public_rt.id
}

########################################################
# SECURITY GROUP — HTTP + SSH
########################################################

resource "aws_security_group" "aws_sg2" {
  name        = "sg_name"
  description = "Allow HTTP, SSH inbound and all outbound"
  vpc_id      = aws_vpc.my_vpc.id

  # ---------------------
  # Allow HTTP
  # ---------------------
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ---------------------
  # Allow SSH
  # ---------------------
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ---------------------
  # Allow ALL outbound
  # ---------------------
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    env = "dev"
  }
}

########################################################
# TARGET GROUP FOR ASG
########################################################

resource "aws_lb_target_group" "tg_asg" {
  name        = "tg-testasg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.my_vpc.id
  target_type = "instance"
}

########################################################
# APPLICATION LOAD BALANCER
########################################################

resource "aws_lb" "test" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.aws_sg2.id
  ]

  subnets = [
    aws_subnet.my_public.id,
    aws_subnet.my_public2.id
  ]

  enable_deletion_protection = false

  tags = {
    env = "dev"
  }
}

########################################################
# LAUNCH TEMPLATE (EC2 CONFIGURATION)
########################################################

resource "aws_launch_template" "demo_template" {
  name_prefix   = "demo-template"
  image_id      = "ami-0ecb62995f68bb549"
  instance_type = "t3.micro"

  # ---------------------
  # User Data (Install Apache)
  # ---------------------
  user_data = base64encode(<<EOF
#!/bin/bash
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "Hello world" > /var/www/html/index.html
EOF
  )
}

########################################################
# AUTO SCALING GROUP
########################################################

resource "aws_autoscaling_group" "my_autosg" {

  desired_capacity = 2
  max_size         = 3
  min_size         = 1

  # ASG Subnets
  vpc_zone_identifier = [
    aws_subnet.my_public.id,
    aws_subnet.my_public2.id
  ]

  # Launch Template reference
  launch_template {
    id      = aws_launch_template.demo_template.id
    version = "$Latest"
  }
}

########################################################
# ATTACH ASG TO LOAD BALANCER TARGET GROUP
########################################################

resource "aws_autoscaling_attachment" "example" {
  autoscaling_group_name = aws_autoscaling_group.my_autosg.id
  lb_target_group_arn    = aws_lb_target_group.tg_asg.arn
}

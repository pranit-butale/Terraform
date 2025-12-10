# Provider
provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "my_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    env  = "dev"
    name = "my_tf_vpc"
  }
}

# Subnets
resource "aws_subnet" "my_public" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.subnet1
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    env  = "dev"
    name = "tf_ps"
  }
}

resource "aws_subnet" "my_public2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.subnet2
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    env  = "dev"
    name = "tf_ps2"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    env  = "dev"
    name = "tf_igw"
  }
}

# Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    env  = "dev"
    name = "public_rt"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.my_public.id
 route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_association2" {
  subnet_id      = aws_subnet.my_public2.id
  route_table_id = aws_route_table.public_rt.id
}

# Security Group
resource "aws_security_group" "aws_sg2" {
  name        = "sg_name"
  description = "Allow HTTP, SSH inbound and all outbound"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

# Load Balancer
resource "aws_lb" "test" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = var.alb_type
  security_groups    = [aws_security_group.aws_sg2.id]
  subnets            = [
    aws_subnet.my_public.id,
    aws_subnet.my_public2.id
  ]

  enable_deletion_protection = false

  tags = {
    env = "dev"
  }
}

# Target Groups
resource "aws_lb_target_group" "tg_asg" {
  name        = "tg-test-asg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.my_vpc.id
  target_type = "instance"

  health_check {
    path     = "/"
    port     = "traffic-port"    
    protocol = "HTTP"
  }
}

resource "aws_lb_target_group" "tg_mobile" {
  name        = "tg-mobile"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.my_vpc.id
  target_type = "instance"

  health_check {
    path     = "/mobile/"
    port     = "traffic-port"    
    protocol = "HTTP"
  }
}

# Listener + Listener Rule
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.test.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_asg.arn
  }
}

resource "aws_lb_listener_rule" "my_lb_listener_rule_mobile" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 102

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_mobile.arn
  }

  condition {
    path_pattern {
      values = ["/mobile/*"]
    }
  }
}



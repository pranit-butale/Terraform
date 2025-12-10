
# Provider
provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "my_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    env  = "dev"
    name = "my_tf_vpc"
  }
}


# Subnets
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
  load_balancer_type = "application"
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
}

resource "aws_lb_target_group" "tg_mobile" {
  name        = "tg-mobile"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.my_vpc.id
  target_type = "instance"

  health_check {
    path     = "/mobile/"
    port     = 80
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

# Launch Templates
resource "aws_launch_template" "demo_template" {
  name_prefix   = "demo-template"
  image_id      = "ami-0ecb62995f68bb549"
  instance_type = "t3.micro"
  key_name = "Virginiakey.pem"

  user_data = base64encode(<<EOF
#!/bin/bash
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "Hello world" > /var/www/html/index.html
EOF
  )
}

resource "aws_launch_template" "demo_mobile" {
  name_prefix   = "demo-mobile"
  image_id      = "ami-0ecb62995f68bb549"
  instance_type = "t3.micro"

  user_data = base64encode(<<EOF
#!/bin/bash
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "welcome to mobile page" > /var/www/html/index.html
EOF
  )
}


# Auto Scaling Groups
resource "aws_autoscaling_group" "my_autosg" {
  desired_capacity   = 2
  max_size           = 3
  min_size           = 1

  vpc_zone_identifier = [
    aws_subnet.my_public.id,
    aws_subnet.my_public2.id
  ]

  launch_template {
    id      = aws_launch_template.demo_template.id
    version = aws_launch_template.demo_template.latest_version
  }

  target_group_arns = [
    aws_lb_target_group.tg_asg.arn
  ]
}

resource "aws_autoscaling_group" "asg_mobile" {
  name             = "asg-mobile"
  desired_capacity = 2
  max_size         = 3
  min_size         = 1

  vpc_zone_identifier = [
    aws_subnet.my_public.id,
    aws_subnet.my_public2.id
  ]

  launch_template {
    id      = aws_launch_template.demo_mobile.id
    version = aws_launch_template.demo_mobile.latest_version
  }

  target_group_arns = [
    aws_lb_target_group.tg_mobile.arn
  ]
}

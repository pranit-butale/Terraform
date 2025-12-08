PROVIDER CONFIGURATION
----------------------

provider "aws" {
  region = "us-east-1"
}



VPC AND SUBNETS
----------------

resource "aws_vpc" "my_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    env  = "dev"
    name = "my_tf_vpc"
  }
}

resource "aws_subnet" "my_public" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.0.0/17"
  availability_zone = "us-east-1a"

  tags = {
    env  = "dev"
    name = "tf_ps"
  }
}

resource "aws_subnet" "my_public2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.128.0/17"
  availability_zone = "us-east-1b"

  tags = {
    env  = "dev"
    name = "tf_ps2"
  }
}



INTERNET GATEWAY AND ROUTES
---------------------------

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    env  = "dev"
    name = "tf_igw"
  }
}

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



SECURITY GROUP
--------------

resource "aws_security_group" "aws_sg2" {
  name        = "sg_name"
  description = "Allow HTTP and SSH"
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



TARGET GROUP
------------

resource "aws_lb_target_group" "tg_asg" {
  name        = "tg_test_asg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.my_vpc.id
  target_type = "instance"
}



APPLICATION LOAD BALANCER
-------------------------

resource "aws_lb" "test" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.aws_sg2.id]

  subnets = [
    aws_subnet.my_public.id,
    aws_subnet.my_public2.id
  ]

  enable_deletion_protection = true

  tags = {
    env = "dev"
  }
}



LAUNCH TEMPLATE
---------------

resource "aws_launch_template" "demo_template" {
  name_prefix   = "demo-template"
  image_id      = "ami-0ecb62995f68bb549"
  instance_type = "t3.micro"

  user_data = base64encode(<<EOF
#!/bin/bash
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "Hello world" > /var/www/html/index.html
EOF
  )
}



AUTO SCALING GROUP
------------------

resource "aws_autoscaling_group" "my_autosg" {
  desired_capacity = 1
  max_size         = 3
  min_size         = 1

  vpc_zone_identifier = [
    aws_subnet.my_public.id,
    aws_subnet.my_public2.id
  ]

  launch_template {
    id      = aws_launch_template.demo_template.id
    version = "$Latest"
  }
}



ATTACH ASG TO TARGET GROUP
--------------------------

resource "aws_autoscaling_attachment" "example" {
  autoscaling_group_name = aws_autoscaling_group.my_autosg.id
  lb_target_group_arn    = aws_lb_target_group.tg_asg.arn
}

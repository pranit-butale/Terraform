


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



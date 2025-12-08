resource "aws_lb_target_group" "tg_asg" {
  name     = "tg-test-asg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id 
  target_type = "instance"
}

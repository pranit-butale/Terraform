resource "aws_launch_template" "demo_template" {
  name_prefix   = "demo-template"
  image_id      = "ami-0ecb62995f68bb549"
  instance_type = "t3.micro"
  host = 

   user_data = base64encode(<<EOF
#!/bin/bash
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "Hello world" > /var/www/html/index.html
EOF
  )
}

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
    version = "$Latest"
  }
}

resource "aws_autoscaling_attachment" "example" {
  autoscaling_group_name = aws_autoscaling_group.my_autosg.id
  lb_target_group_arn = aws_lb_target_group.tg_asg.arn

}

output "vpcid" {
  value = aws_vpc.my_vpc.id
}

output "sg_id" {
  value = aws_security_group.aws_sg2.id
}

output "igw_id" {
  value = aws_internet_gateway.my_igw.id
}

output "alb_dns" {
  value = aws_lb.test.dns_name
}
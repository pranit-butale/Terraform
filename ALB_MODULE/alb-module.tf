provider "aws" {
    region = "us-east-1"
  
}

module "my_alb" {
    source = "../Main-ALB"

    vpc_cidr = var.cidr
    subnet1 = var.subnet1_cidr
    subnet2 = var.subnet2_cidr
    alb_type = var.alb
  
}
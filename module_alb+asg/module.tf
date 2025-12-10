provider "aws" {
    region = "us-east-1"
  
}

module "asg_module" {

    source = "./ASG-main"

    vpc       = var.vpc
    subnet_1  = var.subnet_1
    subnet_2  = var.subnet_2
    lb_type   = var.lb
    ami_id    = var.image_id
    instance_type1 = var.instance_type


    
  
}
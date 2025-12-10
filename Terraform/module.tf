provider "aws" {
    region = "us-east-1"
  
}

module "ec2_tf" {
    source = "./EC2"


    ami = var.ami
    type = var.instance_type
    vpc = var.vpc

    
    
  
}
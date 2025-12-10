provider "aws" {
  region = "us-east-1"
}

module "asg_module" {

  source = "./ASG-main"     # keep correct path

  vpc_cidr        = var.vpc         
  subnet1         = var.subnet_1     
  subnet2         = var.subnet_2     
  lb_type         = var.lb          
  ami_id1         = var.image_id     
  instance_type1  = var.instance_type
}

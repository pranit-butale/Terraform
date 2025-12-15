module "vpc" {
    source = "../Main"

    vpc_cidr1 = var.vpc_cidr
    region1 = var.region 
    instance_tenancy = var.tenancy
    subnet_cidr = var.cidr_subnet

  
}
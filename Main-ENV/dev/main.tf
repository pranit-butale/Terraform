provider "aws" {
    region = "us-east-1"
  
}

resource "aws_instance" "my_instance" {
    ami = var.ami_id
    instance_type = var.instance_type
    key_name = var.key
    vpc_security_group_ids = [var.sg]

    tags = {
      Name = "dev-instance"
      enc = "dev"
    }
  
}
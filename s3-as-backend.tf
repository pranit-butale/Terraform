terraform {
  backend "s3" {
    bucket = "backend-bucket-tfstate-1028"
    key = "terraform.tfstate"
    region = "us-east-1"
    
  }
}

provider "aws" {
    region = "us-east-1"
  
}

resource "aws_instance" "my_instance" {
    ami = "ami-0ecb62995f68bb549"
    instance_type = "t3.micro"
    key_name = "virginiakey"
    vpc_security_group_ids = ["sg-0798e75a64a11e7a6"]

    tags = {
      Name = "dev-instance"
      enc = "dev"
    }
  
}


provider "aws" {
    region = "us-east-1"
  
}

resource "aws_instance" "my_instance" {
    for_each = toset(var.ami_id)
    ami = each.value
    instance_type = "t3.micro"
    key_name = "virginiakey"
    vpc_security_group_ids = ["sg-0798e75a64a11e7a6"]
    

    tags = {
      Name = "dev-instance"
      enc = "dev"
    }
  
}



variable "ami_id" {

  default = ["ami-0ecb62995f68bb549", "ami-068c0051b15cdb816", "ami-069e612f612be3a2b"]
  
}

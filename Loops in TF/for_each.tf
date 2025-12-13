provider "aws" {
    region = "us-east-1"

  
}

resource "aws_instance" "my_instance" {
    ami = each.key
    instance_type = "t3.micro"
    key_name = "virginiakey"
    vpc_security_group_ids = [ "sg-02dddca7ec2ea5f84" ]
    for_each = toset(var.ami)
    
  
}





variable "ami" {
    default = ["ami-068c0051b15cdb816", "ami-0ecb62995f68bb549","ami-069e612f612be3a2b"]
  
}
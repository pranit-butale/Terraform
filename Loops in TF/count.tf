provider "aws" {
    region = "us-east-1"

  
}

resource "aws_instance" "my-instance" {
    ami = "ami-0ecb62995f68bb549"
    instance_type = "t3.micro"
    key_name = "virginiakey"
    vpc_security_group_ids = [ "sg-02dddca7ec2ea5f84" ]
    count = 4
  
}
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "my_instance" {
  ami                    = "ami-0ecb62995f68bb549"
  instance_type          = "t3.micro"
  key_name               = "virginiakey"
  vpc_security_group_ids = ["sg-02dddca7ec2ea5f84"]
  provisioner "local-exec" {
    command = "echo ec2 instance will be created successfully"
    
  }

  


  tags = {
    Name = "nginx-provisioner-local"
  }
}

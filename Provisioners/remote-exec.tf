provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "my_instance" {
  ami                    = "ami-0ecb62995f68bb549"
  instance_type          = "t3.micro"
  key_name               = "virginiakey"
  vpc_security_group_ids = ["sg-02dddca7ec2ea5f84"]

  
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("virginiakey.pem")
    host        = self.public_ip
  }

  
  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y nginx",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx"
    ]
  }

  tags = {
    Name = "nginx-provisioner"
  }
}

variable "vpc" {
    default = "10.0.0.0/16"
  
}

variable "subnet_1" {
    default = "10.0.0.0/17"
  
}

variable "subnet_2" {
    default = "10.0.128.0/17"
  
}

variable "lb" {
    default = "application"
  
}

variable "image_id" {
    default = "ami-0ecb62995f68bb549"
  
}

variable "instance_type" {
    default = "t3.micro"
  
}
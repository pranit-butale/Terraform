provider "aws" {
    region = "us-east-1"
  
}

resource "aws_s3_bucket" "s3_bucket" {
    bucket = "my-demo-bucket-sp-1028"
    force_destroy = true

    tags = {
      Name = "my-bucket"
      Env = "dev"
    }
  
}

resource "aws_s3_bucket_object" "s3_object" {
    bucket = aws_s3_bucket.s3_bucket.bucket 
    key = "index.html"
    source = "C:/root/index.html"
  
}

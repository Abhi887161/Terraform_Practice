locals {
  region = "us-east-1"
  instance_type = "t2.micro"
}
  resource "aws_instance" "name" {
    ami = "ami-002f6e91abff6eb96"
    instance_type = local.instance_type
    tags = {
      Name = "App-${local.region}"
      
    }
  }
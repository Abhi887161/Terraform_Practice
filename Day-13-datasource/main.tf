
provider "aws" {
    region = "ap-south-1"
  
}

data "aws_subnet" "name" {
    filter {
    name   = "tag:Name"
    values = ["dev"] # insert value here
  }
}   
  
data "aws_ami" "amzlinux" {
  most_recent = true
  owners = [ "545009839249" ]
  filter {
    name = "name"
    values = [ "Ec2-S3" ]
  }
  filter {
    name = "root-device-type"
    values = [ "ebs" ]
  }
  filter {
    name = "virtualization-type"
    values = [ "hvm" ]
  }
  filter {
    name = "architecture"
    values = [ "x86_64" ]
  }
}

# data "aws_ami" "amzlinux" {
#   most_recent = true
#   owners = [ "self" ]
#  filter {
#     name   = "name"
#     values = ["ami-node1"]
#   }
# }
resource "aws_instance" "name" {
    ami = data.aws_ami.amzlinux.id
    instance_type = "t2.micro"
    subnet_id = data.aws_subnet.name.id

}
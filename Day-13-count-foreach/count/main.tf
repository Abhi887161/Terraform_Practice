resource "aws_instance" "name" {
    ami = "ami-085ad6ae776d8f09c"
     instance_type = "t2.micro"
     key_name = "ec2test"
     availability_zone = "us-east-1a"
     count = 2
     

     tags = {
       Name = "dev-${count.index}"
     }
 }#here instance will cretae with name dev0 and dev1

 ############################### Example-2 Different names #############
# variable "env" {
#   type    = list(string)
#   default = [ "dev", "test", "prod"]
# }

# resource "aws_instance" "name" {
#     ami = "ami-085ad6ae776d8f09c"
#     instance_type = "t2.micro"
#     count=length(var.env)

#     tags = {
#       Name = var.env[count.index]
#     }
# }
# here three instance will create with dev, test and prod

# ## example-2 with variables list of string 

 variable "ami" {
   type    = string
   default = "ami-0440d3b780d96b29d"
 }

 variable "instance_type" {
   type    = string
   default = "t2.micro"
 }

 variable "sandboxes" {
   type    = list(string)
   default = [ "server1", "server2"]
 }

# main.tf
    resource "aws_instance" "sandbox" {
  ami           = var.ami
   instance_type = var.instance_type
   count         = length(var.sandboxes)

   tags = {
     Name = var.sandboxes[count.index]
   }
 }


   
  
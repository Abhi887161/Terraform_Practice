    resource "aws_instance" "name" {
    ami = var.amiID
    instance_type = var.instance_type
    tags = {
            Name = "First_Server"
    }
  
}
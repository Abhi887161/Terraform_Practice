resource "aws_instance" "name" {
    ami = "ami-0f1dcc636b69a6438"
    instance_type = "t2.micro"

    tags = {
        Name = "null resource"
    }


provisioner "local-exec" {
    command = "echo Instance private IP is ${self.private_ip} > abhi.txt"
  
}

}
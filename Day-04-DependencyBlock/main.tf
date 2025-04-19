resource "aws_instance" "dev" {
    ami = "ami-002f6e91abff6eb96"
    instance_type = "t2.micro"
  
}

resource "aws_vpc" "name" {
    cidr_block = "10.0.0.0/16"
    depends_on = [ aws_instance.dev ]
}

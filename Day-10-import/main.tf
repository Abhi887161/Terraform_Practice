resource "aws_instance" "dev" {
  ami = "ami-062f0cc54dbfd8ef1"
  instance_type = "t2.micro"
  subnet_id = "subnet-01768c9e5f0a88e78"

tags = {
  Name = "ec2"
}


}

resource "aws_instance" "dev" {
  ami = "ami-062f0cc54dbfd8ef1"
  instance_type = "t2.micro"
  user_data = file("test.sh")


tags = {
  Name = "userdata"
}
}
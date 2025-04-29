provider "aws" {
    region = "ap-south-1"
  
}

resource "aws_key_pair" "name" {
    key_name = "task"
    public_key = file("~/.ssh/id_ed25519.pub") 
  
}

resource "aws_instance" "name" {
    ami = "ami-0f1dcc636b69a6438"
    instance_type = "t2.micro"
    key_name = aws_key_pair.name.key_name

    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = file("~/.ssh/id_ed25519")
      host = self.public_ip
    }

    provisioner "local-exec" {
    command = "type nul > file500"
   
 }

    provisioner "file" {
        source = "file100"
        destination = "/home/ubuntu/file100"  

    }

    provisioner "remote-exec" {
        inline = [ 
            "touch file200",
            "echo hello from aws >> file200",
         ]
      
    }
  
}

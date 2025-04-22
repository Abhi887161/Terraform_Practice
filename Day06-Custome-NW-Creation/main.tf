#Create VPC
resource "aws_vpc" "dev" {
    cidr_block = "10.0.0.0/16"
     tags = {
      Name = "Dev"
    }
     
}
# Create public subnet
resource "aws_subnet" "public" {
vpc_id = aws_vpc.dev.id
cidr_block = "10.0.0.0/24"
availability_zone = "ap-south-1a"
}

#Create private subnet

resource "aws_subnet" "private" {
vpc_id = aws_vpc.dev.id
cidr_block = "10.0.1.0/24"
availability_zone = "ap-south-1b"

  
}

# Create IG
resource "aws_internet_gateway" "name" {
   vpc_id = aws_vpc.dev.id 
  
}

#Create NG Elastic IP Allocate

 resource "aws_eip" "name" {
    domain = "vpc"
  
} 

#Create NG
resource "aws_nat_gateway" "name" {
    subnet_id = aws_subnet.private.id
    allocation_id = aws_eip.name.id

    tags = {
        Name = "gw NAT"
    }

}

# Create public RT
resource "aws_route_table" "name" {
    vpc_id = aws_vpc.dev.id
   #Edit Routes
   route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.name.id

   }
}

# Subnet Association#
resource "aws_route_table_association" "public1" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.name.id

}
#Crate private RT
resource "aws_route_table" "privateRoute" {
        vpc_id = aws_vpc.dev.id
        #Edit Route 
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.name.id
    } 
  
}

resource "aws_route_table_association" "private" {
    subnet_id = aws_subnet.private.id
    route_table_id = aws_route_table.privateRoute.id
  
}

# Create SG
resource "aws_security_group" "allow" {
name = "allow"
vpc_id = aws_vpc.dev.id
tags = {
  Name = "dev_sg"
}
ingress  {
    description = "Allow port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks  = ["0.0.0.0/0"]
}

 ingress{
    description = "Allow port 22"
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]

}

egress  {
    from_port       = 0
    to_port         = 0
    protocol        = "-1" 
    cidr_blocks      = ["0.0.0.0/0"]
 }

}
resource "aws_key_pair" "devtest" {
    key_name = "devtest"
    public_key = file("~/.ssh/id_ed25519.pub") #here you need to define public key file path
  
}


# Lunch public Server
resource "aws_instance" "publicserver" {
    ami = "ami-002f6e91abff6eb96"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.public.id
    associate_public_ip_address = true
    key_name =  aws_key_pair.devtest.key_name
    vpc_security_group_ids = [aws_security_group.allow.id]

    tags = {
      Name = "Public_Server"
    }
  
}

# Lunch Private Server
resource "aws_instance" "privateserver" {
    ami = "ami-002f6e91abff6eb96"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.private.id
    key_name =  aws_key_pair.devtest.key_name
    vpc_security_group_ids = [aws_security_group.allow.id]

    tags = {
      Name = "Private_Server"
    }
  
}

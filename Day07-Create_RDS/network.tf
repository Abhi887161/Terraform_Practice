resource "aws_vpc" "name" {
    provider                    =aws.primary
    cidr_block                  = "10.0.0.0/16"
    enable_dns_support          = true
    enable_dns_hostnames        = true


    tags = {
        Name = "devVPC"
    }
  
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.name.id

    tags = {
      Name = "dev_IG"
    }
}

resource "aws_subnet" "publicSubnet1" {
    vpc_id              = aws_vpc.name.id
    cidr_block          = "10.0.1.0/24" 
    availability_zone   = "ap-south-1a"
    tags = {
      Name = "Subnet1"
    }
  
}

resource "aws_subnet" "publicSubnet2" {
    vpc_id                  =   aws_vpc.name.id
    cidr_block              =   "10.0.0.0/24"
    availability_zone       =   "ap-south-1b"
    tags = {
      Name = "Subnet2"
    }
}

resource "aws_route_table" "rt" {
    vpc_id = aws_vpc.name.id
    route  {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id

    }  
}

resource "aws_route_table_association" "rt-association1" {
    route_table_id = aws_route_table.rt.id
    subnet_id = aws_subnet.publicSubnet1.id
  
}

resource "aws_route_table_association" "rt-association2" {
    route_table_id = aws_route_table.rt.id
    subnet_id = aws_subnet.publicSubnet2.id
}

resource "aws_security_group" "security-group" {
  vpc_id      = aws_vpc.name.id
  description = "Allowing Jenkins, Sonarqube, SSH Access"

  ingress = [
    for port in [22, 9000, 8080, 9090, 3306, 80] : {
      description      = "TLS from VPC"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      ipv6_cidr_blocks = ["::/0"]
      self             = false
      prefix_list_ids  = []
      security_groups  = []
      cidr_blocks      = ["0.0.0.0/0"]
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DevSG"
  }
}


#Creating newtorking for secondary region for read replica

resource "aws_vpc" "secondaryregion" {
    provider = aws.secondary
    cidr_block = "10.1.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true


    tags = {
        Name = "SecondaryVPC"
    }
  
}

resource "aws_subnet" "subnet1_Secondary" {
  vpc_id             = aws_vpc.secondaryregion.id
  provider = aws.secondary
  cidr_block         = "10.1.1.0/24"
  availability_zone   = "us-east-1a"

  tags = {
    Name = "secondarysubnet1"
  }

}


resource "aws_subnet" "subnet2_Secondary" {
    vpc_id = aws_vpc.secondaryregion.id
    provider = aws.secondary
    cidr_block = "10.1.2.0/24"
    availability_zone = "us-east-1b"
    tags = {
      Name = "secondarysubnet2"
    }
  
}

resource "aws_internet_gateway" "secondary_IG" {
   provider = aws.secondary
   vpc_id = aws_vpc.secondaryregion.id

}

resource "aws_route_table" "secondaryrt" {
    provider = aws.secondary
    vpc_id = aws_vpc.secondaryregion.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.secondary_IG.id
    }
  
}

resource "aws_route_table_association" "secondaryRTA1" {
    provider = aws.secondary
    route_table_id = aws_route_table.secondaryrt.id
    subnet_id = aws_subnet.subnet1_Secondary.id
  
}

resource "aws_route_table_association" "secondaryRTA2" {
    provider = aws.secondary
    route_table_id = aws_route_table.secondaryrt.id
    subnet_id = aws_subnet.subnet2_Secondary.id
  
}

resource "aws_security_group" "secondary_sg" {
  provider = aws.secondary
  vpc_id   = aws_vpc.secondaryregion.id
  description = "Allow MySQL access"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Change for production!
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SecondaryDBSG"
  }
}
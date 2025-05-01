resource "aws_vpc" "name" {

     cidr_block                  = "10.0.0.0/16"
     enable_dns_support   = true
     enable_dns_hostnames = true
    tags = {
        
        Name = "devVPC"
    }
  
}
  
resource "aws_subnet" "publicSubnet1" {
    vpc_id              = aws_vpc.name.id
    cidr_block          = "10.0.0.0/24" 
    availability_zone   = "ap-south-1a"
    tags = {
      Name = "PublicSubnet1"
    }
  
}

resource "aws_subnet" "privateSubnet1" {
    vpc_id              = aws_vpc.name.id
    cidr_block          = "10.0.1.0/24" 
    availability_zone   = "ap-south-1b"
    tags = {
      Name = "PrivateSubnet1"
    }
  
}

resource "aws_subnet" "privateSubnet2" {
    vpc_id                  =   aws_vpc.name.id
    cidr_block              =   "10.0.2.0/24"
    availability_zone       =   "ap-south-1c"
    tags = {
      Name = "PrivateSubnet2"
    }
}


resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.name.id

    tags = {
      Name = "dev_IG"
    }
}


# public route tabel
resource "aws_route_table" "rtpublic" {
    vpc_id = aws_vpc.name.id
    route  {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        Name = "Public-RT"
    }   
}

resource "aws_route_table_association" "rt-association1" {
    route_table_id = aws_route_table.rtpublic.id
    subnet_id = aws_subnet.publicSubnet1.id
  
}

#private Nat Gateway

resource "aws_eip" "nat" {
    domain = "vpc"
}

resource "aws_nat_gateway" "name" {
    subnet_id = aws_subnet.publicSubnet1.id
    allocation_id = aws_eip.nat.id

    tags = {
      Name = "natpublic"
    }
  
}
resource "aws_route_table" "privateroute" {
  vpc_id = aws_vpc.name.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.name.id
  }

  tags = {
    Name = "Private-RT"
  }
}


resource "aws_route_table_association" "private1" {
    subnet_id = aws_subnet.privateSubnet1.id
    route_table_id = aws_route_table.privateroute.id
  
}


resource "aws_route_table_association" "private2" {
    subnet_id = aws_subnet.privateSubnet2.id
    route_table_id = aws_route_table.privateroute.id
  
}

#create SG
variable "allowed_ports" {
  type = map(string)
  default = {
    "22"   = "0.0.0.0/0"
    "80"   = "0.0.0.0/0"
    "443"  = "0.0.0.0/0"
    "8080" = "10.0.0.0/16"
    "9000" = "192.168.1.0/24"
    "3306" = "0.0.0.0/0"
  }
}

resource "aws_security_group" "allow" {
  name   = "allow"
  vpc_id = aws_vpc.name.id

  tags = {
    Name = "dev_sg"
  }

  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      description = "Allow access to port ${ingress.key}"
      from_port   = tonumber(ingress.key)
      to_port     = tonumber(ingress.key)
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_vpc_endpoint" "secretsmanager_endpoint" {
  vpc_id              = aws_vpc.name.id
  service_name        = "com.amazonaws.ap-south-1.secretsmanager"
  vpc_endpoint_type   = "Interface"  # <-- ADD THIS
  subnet_ids          = [aws_subnet.privateSubnet1.id, aws_subnet.privateSubnet2.id]
  security_group_ids  = [aws_security_group.allow.id]
  private_dns_enabled = true

  tags = {
    Name = "secretsmanager-vpc-endpoint"
  }
}

# Create the Secrets Manager secret
resource "aws_secretsmanager_secret" "rds_credentials" {
  name        = "rds_admin_credentials_V2"
  description = "Credentials for RDS admin access"
}

# Store the secret values (username & password)
resource "aws_secretsmanager_secret_version" "rds_credentials_version" {
  secret_id     = aws_secretsmanager_secret.rds_credentials.id
  secret_string = jsonencode({
    username = "admin"
    password = "admin123"
  })
}


resource "aws_db_instance" "rds" {
  allocated_storage           = 20
  identifier                  = "book-rds"
  db_subnet_group_name        = aws_db_subnet_group.RDS-Subnet.id
  engine                      = "mysql"
  engine_version              = "8.0"
  instance_class              = "db.t3.micro"
  multi_az                    = true
  db_name                     = "dev"
  username                    = jsondecode(aws_secretsmanager_secret_version.rds_credentials_version.secret_string)["username"]
  password                    = jsondecode(aws_secretsmanager_secret_version.rds_credentials_version.secret_string)["password"]
  skip_final_snapshot         = true
  vpc_security_group_ids      = [aws_security_group.allow.id]
  publicly_accessible         = false
  backup_retention_period     = 7 

  depends_on = [aws_db_subnet_group.RDS-Subnet]

  tags = {
    DB_identifier = "book-rds"
  }
}



resource "aws_db_subnet_group" "RDS-Subnet" {
    name        = "main"
    subnet_ids  = [aws_subnet.privateSubnet1.id, aws_subnet.privateSubnet2.id]
    tags = {
        Name = "SUbnet Group"
    } 
  
}

resource "aws_key_pair" "devtest" {
        key_name = "devtest"
        public_key = file("~/.ssh/id_ed25519.pub") #here you need to define public key file path
    
    }


# Example EC2 instance (replace with yours if already existing)
resource "aws_instance" "createsql" {
  ami                    = "ami-0f1dcc636b69a6438" 
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.publicSubnet1.id
  key_name               = "devtest"      # Replace with your key pair name
  vpc_security_group_ids = [aws_security_group.allow.id]
  associate_public_ip_address = true

  tags = {
    Name = "SQL Runner"
  }
}

# Deploy SQL remotely using null_resource + remote-exec
resource "null_resource" "remote_sql_exec" {
  depends_on = [aws_db_instance.rds, aws_instance.createsql]

    connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_ed25519")
    host        = aws_instance.createsql.public_ip
    timeout     = "15m"

    }

      provisioner "file" {
    source      = "init.sql"
    destination = "/tmp/init.sql"
  }

  provisioner "remote-exec" {


    inline = [      
      "sudo yum update -y",
      "sudo yum install -y mariadb105-server",                                
      "mysql -h ${aws_db_instance.rds.address} -u ${jsondecode(aws_secretsmanager_secret_version.rds_credentials_version.secret_string)["username"]} -p${jsondecode(aws_secretsmanager_secret_version.rds_credentials_version.secret_string)["password"]} < /tmp/init.sql"

     // "mysql-h book-rds.cn4gsoueid50.ap-south-1.rds.amazonaws.com -u admin -pGiraffe$Sunset92!BananaTree < /tmp/init.sql"
    ]
  }

  triggers = {
    always_run = timestamp() #trigger every time apply 
  }
}


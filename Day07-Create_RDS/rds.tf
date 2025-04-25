resource "aws_db_instance" "rds" {

    provider                    = aws.primary
    allocated_storage           = 20
    identifier                  = "book-rds"
    db_subnet_group_name        = aws_db_subnet_group.sub-grp.id  
    engine                      = "MySQL"
    engine_version              = "8.0"
    instance_class              = "db.t3.micro"
    multi_az                    = true
    db_name                     = "mydbterraform"
    username                    = "admin"
    password                    = "Giraffe$Sunset92!BananaTree" 
    skip_final_snapshot         = true
    vpc_security_group_ids      = [aws_security_group.security-group.id]
    publicly_accessible         = true
    backup_retention_period     = 7 
    depends_on = [ aws_db_subnet_group.sub-grp ]

    tags = {
        DB_identifier = "book-rds"
    }
}

resource "aws_db_subnet_group" "sub-grp" {
    name        = "main"
    subnet_ids  = [aws_subnet.publicSubnet1.id, aws_subnet.publicSubnet2.id]
    tags = {
        Name = "DB SUbnet Group"
    } 
  
}


# Create Read Replica
# data "aws_db_instance" "book_rds_primary" {
#     provider = aws.primary
#     db_instance_identifier = "book-rds"
  
# }

resource "aws_db_instance" "readreplica" {
    provider                        = aws.secondary
    identifier                      = "book-rds-replica"
    replicate_source_db             = aws_db_instance.rds.arn
    instance_class                  = "db.t3.micro"
    publicly_accessible             = true
    skip_final_snapshot             = true
    db_subnet_group_name            = aws_db_subnet_group.secondary_db_subnet_group.id
    vpc_security_group_ids          = [aws_security_group.secondary_sg.id]
    auto_minor_version_upgrade      = true
    deletion_protection             = false  
    depends_on                       = [aws_db_subnet_group.secondary_db_subnet_group]
   
}

resource "aws_db_subnet_group" "secondary_db_subnet_group" {
  provider   = aws.secondary
  name       = "secondary-db-subnet-group"
  subnet_ids = [
    aws_subnet.subnet1_Secondary.id,
    aws_subnet.subnet2_Secondary.id

  ]

  tags = {
    Name = "SecondaryDBSubnetGroup"
  }
}


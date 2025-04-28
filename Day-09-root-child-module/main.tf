module "ec2" {
    source = "./module/ec2-instance"
    ami = var.ami
    instance_type = var.instance_type
    instance_name = var.instance_name
}

module "S3" {
    source = "./module/S3"
    bucket_name = var.bucket_name
    environment = var.environment
  
}
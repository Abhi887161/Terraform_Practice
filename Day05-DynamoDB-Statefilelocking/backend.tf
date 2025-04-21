terraform {
  backend "s3" {
    bucket = "dynamodbtestmain"
    key = "terraform.tfstate"
    region = "ap-south-1"
    dynamodb_table = "terraform-state-file-lock-dynamo"
    encrypt = true
    
  }
}
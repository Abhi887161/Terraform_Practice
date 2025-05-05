provider "aws" {
    profile = "dev"
    alias = "account1"
    region = "ap-south-1"
  
}

provider "aws" {
    profile = "test"
    alias = "account2"
    region = "us-east-1"
}

resource "aws_s3_bucket" "name" {

    bucket = "test-awa-bucket-grewal1"
    provider = aws.account2
    
}

resource "aws_s3_bucket" "name" {
    bucket = "test-aws-usd-grewal1"
    provider = aws.account2
  
}
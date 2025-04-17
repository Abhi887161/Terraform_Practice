resource "aws_instance" "abhi" {

ami = var.amiID
instance_type = var.instance_type

}

resource "aws_s3_bucket" "newbucket" {
    bucket = var.bucket_Name
    
}
output "IP" {
    value =aws_instance.abhi.public_ip
  
}
output "Private_IP" {
    value = aws_instance.abhi.private_ip
  
}
output "AZ" {
    value = aws_instance.abhi.availability_zone
    sensitive = true
 
}
output "S3" {
    value = aws_s3_bucket.newbucket.website_endpoint
  
}


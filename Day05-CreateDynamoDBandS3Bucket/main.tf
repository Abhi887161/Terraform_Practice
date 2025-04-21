resource "aws_s3_bucket" "test" {

bucket = "dynamodbtestmain"
  
}

resource "aws_dynamodb_table" "name" {
  name = "terraform-state-file-lock-dynamo"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }
}
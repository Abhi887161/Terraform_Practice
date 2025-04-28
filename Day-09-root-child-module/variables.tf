variable "ami" {
    type = string
    default = "ami-0f1dcc636b69a6438"
}

variable "instance_type" {
    type = string
    default = "t2.medium"
}

variable "instance_name" {
    type = string
    default = "QA"
  
}

variable "bucket_name" {
    type =  string
    default = "my-unique-bucket-name-20252211"
}
variable "environment" {
    type =  string
    default = "dev"
}

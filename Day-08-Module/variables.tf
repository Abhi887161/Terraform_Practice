variable "ami" {
  type = string
  default = ""
}
variable "instance_type" {
  type = string
  default = ""
  
}

variable "subnet_id" {
  description = "Subnet ID to launch the instance in"
  type        = string
  default = ""
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
  default = [ "" ]
}
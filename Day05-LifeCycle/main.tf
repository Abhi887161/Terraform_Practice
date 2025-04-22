resource "aws_instance" "dev"{
    ami = "ami-002f6e91abff6eb96"

    instance_type = "t2.micro"

    availability_zone = "ap-south-1a"

    tags = {
        Name = "UAT"
    }

    # lifecycle{
    #         prevent_destroy = true
    #     }
    # lifecycle {
    #   ignore_changes = [ tags, ]
    # }

#     lifecycle {
#       create_before_destroy = true
#     }
}

        

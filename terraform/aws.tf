# provider "random" {}

# resource "random_pet" "name" {}

# resource "aws_instance" "web" {
#   ami           = "ami-0742b4e673072066f"
#   instance_type = "t2.micro"
#   user_data     = file("init-script.sh")

#   tags = {
#     Name = random_pet.name.id
#   }
# }

# output "domain-name" {
#   value = aws_instance.web.public_dns
# }

# output "application-url" {
#   value = "${aws_instance.web.public_dns}/index.php"
# }
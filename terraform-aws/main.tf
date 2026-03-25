# main.tf
provider "aws" {

     region = "eu-north-1"
}

#create s3 bucket 
resource "aws_s3_bucket" "my_bucket" {
bucket = "shrik-s3-bucket-96741"

}
resource "aws_instance" "my_ec2" {
ami            ="ami-017535a27f2ac0ce3"
instance_type  ="t3.micro"
tags = {
 Name = "terraform-ec2-shrik"
}
}          

# This tells Terraform to save the IP so Jenkins can read it
output "ec2_public_ip" {
  value       = aws_instance.my_ec2.public_ip
  description = "The public IP of the web server"
}

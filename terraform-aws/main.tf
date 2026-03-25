# main.tf
provider "aws" {

     region = "eu-north-1"
}

#create s3 bucket 
resource "aws_s3_bucket" "my_bucket" {
bucket = "shrik-s3-bucket-96741"
acl    = "private"
}
resource "aws_instance" "my_ec2" {
ami            ="ami-017535a27f2ac0ce3"
instance_type  ="t3.micro"
tags = {
 Name = "terraform-ec2-shrik"
}
}          

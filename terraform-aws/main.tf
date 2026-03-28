# main.tf

provider "aws" {

     region = "eu-north-1"
}


# This tells Terraform to save the IP so Jenkins can read it
output "ec2_public_ip" {
  value       = aws_instance.my_ec2.public_ip
  description = "The public IP of the web server"
}

resource "aws_security_group" "web_sg1" {
  name        = "web-sg1"
  description = "Allow SSH and app access"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "App Port"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "my_ec2" {
ami            ="ami-017535a27f2ac0ce3"
instance_type  ="t3.micro"
key_name = "shrik-1234"
vpc_security_group_ids = [aws_security_group.web_sg1.id]
user_data = <<-EOF
#!/bin/bash

exec > /home/ec2-user/setup.log 2>&1

yum update -y

# Check if amazon-linux-extras exists (AL2) or use fallback
if command -v amazon-linux-extras >/dev/null; then
    amazon-linux-extras install docker -y
else
    yum install -y docker
fi

systemctl start docker
systemctl enable docker

usermod -aG docker ec2-user

# Ensure the socket is accessible (optional)
chmod 666 /var/run/docker.sock

echo "Docker setup completed"

EOF
  user_data_replace_on_change = true
tags = {
 Name = "terraform-ec2-shrik"
}
}    

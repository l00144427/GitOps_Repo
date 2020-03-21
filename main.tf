# Terraform state will be stored in S3
terraform {
  backend "s3" {
    bucket = "terraform-bucket-l00144427-student"
    key    = "terraform.tfstate"
    region = "eu-west-1"
  }
}

# Use AWS Terraform provider
provider "aws" {
  region = "eu-west-1"
}

# Create EC2 instance
resource "aws_instance" "default" {
  ami                    = var.ami
  count                  = var.instance_count
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.default.id]
  source_dest_check      = false
  instance_type          = var.instance_type

provisioner "file" {
  source="install_nginx.sh"
  destination="/tmp/install_nginx.sh"
}
provisioner "remote-exec" {
  inline=[
  "chmod +x /tmp/install_nginx.sh",
  "sudo /tmp/install_nginx.sh"
]
  tags = {
    Name = "terraform-default"
  }
}

# Create Security Group for EC2
resource "aws_security_group" "default" {
  name = "terraform-default-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["109.78.37.103/32"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["109.78.37.103/32"]
  }

}

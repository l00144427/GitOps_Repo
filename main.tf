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
  version = "2.54"
}

# Create EC2 instance
resource "aws_instance" "default" {
  ami                    = var.ami
  count                  = var.instance_count
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.default.id]
  source_dest_check      = false
  instance_type          = var.instance_type
  
  connection {
    private_key = "var.key_name"
    host        = "default"
    user        = "ubuntu"

    # Ansible requires Python to be installed on the remote machine as well as the local machine.
    provisioner "remote-exec" {
      inline = ["sudo apt-get -qq install python -y"]
    }
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

  ingress {
    from_port   = 8081
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["109.78.37.103/32"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    security_groups = ["sg-095576bc1688d6b7a"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    security_groups = ["sg-095576bc1688d6b7a"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

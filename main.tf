# Terraform state will be stored in S3
terraform {
  backend "s3" {
    bucket = "terraform-bucket-l00144427"
    key    = "terraform.tfstate"
    region = "us-east-2"
  }
}

# Use AWS Terraform provider
provider "aws" {
  region = "us-east-2"
  #assume_role {
  #  role_arn     = "arn:aws:iam::279620518215:role/S3_Role"
  #  session_name = "SESSION_NAME"
  #  external_id  = "EXTERNAL_ID"
  #}
  access_key = "AKIAZHKULKPYHQ3AGXXU"
  secret_key = "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"
  # shared_credentials_file = "/var/jenkins_home/.aws/credentials"
}

# Create EC2 instance
resource "aws_instance" "default" {
  ami                    = var.ami
  count                  = var.instance_count
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.default.id]
  source_dest_check      = false
  instance_type          = var.instance_type

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
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

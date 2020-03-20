variable "instance_count" {
  default = 1
}

variable "key_name" {
  description = "Private key name to use with instance"
  default     = "GitOpsKey"
}

variable "instance_type" {
  description = "AWS instance type"
  default     = "t2.micro"
}

variable "ami" {
  description = "Base AMI to launch the instances"

  # ubuntu-xenial-16.04-amd64-server-20200129
  default = "ami-0f630a3f40b1eb0b8"
}

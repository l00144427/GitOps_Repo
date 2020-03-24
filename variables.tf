variable "instance_count" {
  default = 1
}

variable "key_name" {
  description = "Private key to use with instance"
  default     = "GitOpsKey"
}

variable "instance_type" {
  description = "AWS instance"
  default     = "t2.medium"
}

variable "ami" {
  description = "AMI used to launch the instance"

  # ubuntu-xenial-16.04-amd64-server-20200129
  default = "ami-0f630a3f40b1eb0b8"
}

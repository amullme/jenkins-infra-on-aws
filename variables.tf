variable "allowed_cidr" {
  description = "The security group will block all but this CIDR"
  type        = string
  default     = "0.0.0.0/0"
}


variable "key_pair" {
  description = "The already existing keypair used to ssh"
  type        = string
  default     = "jenkins_kp"
}

variable "region" {
  description = "The region in which the resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "ami" {
  description = "Use the latest Amazon Linux 2 AMI for your region"
  type        = string
  default     = "ami-04aa00acb1165b32a"
}


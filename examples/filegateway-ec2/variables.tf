variable "aws_region" {
  type        = string
  description = "Region for AWS Resources"
  default     = "us-east-1"
}

variable "project" {
  type        = string
  description = "Name of the project"
  default     = "Test"
}

#variable "naming_prefix" {
#  type        = string
#  description = "prefix used to name resources"
#  default     = "demo"
#}

variable "vpc-ipv4-cidr" {
  type        = string
  description = "Network CIDR for the VPC"
  default     = "172.16.0.0/16"
}

variable "subnet-count" {
  type        = number
  description = "Number of sunbets per type"
  default     = 6
}

variable "image_id" {
  type        = string
  description = "EC2 storage gateway AMI ID"
  default     = "ami-05257a1f7eff27687"
}

variable "instance_type" {
  type        = string
  description = "EC2 Instance Type"
  default     = "m5.xlarge"
}

variable "gateway_name" {
  type        = string
  description = "EC2 File Gateway Name"
  default     = "ec2-sgw-01"
}

variable "ssh_key_name" {
  type        = string
  description = "SSH keypair for EC2"
  default     = "surampa"
}

variable "name" {
  default     = "aws-storage-gateway"
  type        = string
  description = "Name of the storage gateway instance that will be created in EC2"
}

variable "aws_region" {
  type        = string
  description = "Region for AWS Resources"
  default     = ""
}

# variable "availability_zone" {
#   type        = string
#   description = "Availability zone for the Gateway Ec2 Instance."
#   default     = ""
# }

variable "allow_unverified_ssl" {
  type        = bool
  description = "Boolean that can be set to true to disable SSL certificate verification."
  default     = false
}

variable  "vpc_cidr_block" {
 type = string
 description = "VPC CIDR blocks"
 default = ""
}

variable "client_list" {
  type        = list(any)
  sensitive   = true
  description = "The list of clients that are allowed to access the file gateway. The list must contain either valid IP addresses or valid CIDR blocks. Minimum 1 item. Maximum 100 items."
}

variable "subnet-count" {
  type        = number
  description = "Number of sunbets per type"
  default     = 1
}

variable "name" {
  default     = "aws-storage-gateway"
  type        = string
  description = "Name of the storage gateway instance that will be created in EC2"
}

variable "aws_region" {
  type        = string
  description = "The name of the region you wish to deploy into"
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

variable "vpc_cidr_block" {
  type        = string
  description = "VPC CIDR block for the creation of example VPC and subnets"
  default     = "10.0.0.0/16"
}

variable "domain_name" {
  type        = string
  sensitive   = true
  description = "Domain name"
}

variable "domain_username" {
  type        = string
  sensitive   = true
  description = "The user name for the service account on your self-managed AD domain that SGW use to join to your AD domain"
}

variable "domain_password" {
  type        = string
  sensitive   = true
  description = "The password for the service account on your self-managed AD domain that SGW will use to join to your AD domain"
}

variable "domain_controllers" {
  default     = []
  type        = list(any)
  sensitive   = true
  description = "Comma separated list of domain controllers."
}

variable "subnet-count" {
  type        = number
  description = "Number of sunbets per type"
  default     = 1
}

variable "ingress_cidr_blocks" {
  type        = string
  description = "The CIDR blocks to allow ingress into your File Gateway instance for NFS and SMB client access. For multiple CIDR blocks, please separate with comma"
  default     = "10.0.0.0/16"
}
variable "ingress_cidr_block_activation" {
  type        = string
  description = "The CIDR block to allow ingress port 80 into your File Gateway instance for activation. For multiple CIDR blocks, please separate with comma"
  # default     = "0.0.0.0/0"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Absolute file path to the the public key for the EC2 Key pair"
}
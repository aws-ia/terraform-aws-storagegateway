variable "aws_region" {
  type        = string
  description = "Region for AWS Resources"
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPC CIDR block for the creation of example VPC and subnets"
  default     = "10.0.0.0/16"
}

variable "client_ip_cidrs" {
  type        = string
  sensitive   = true
  description = "The IP addresses or CIDR block of clients that are allowed to access the file gateway. If there are multiple clients, please separate using commas. The value must contain valid CIDR blocks. Minimum 1 item. Maximum 100 items."
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
}

variable "ssh_public_key_path" {
  type        = string
  description = "(Optional) Absolute file path to the the public key for the EC2 Key pair. If ommitted, the EC2 key pair resource will not be created"
  default     = ""
}

variable "ssh_key_name" {
  type        = string
  description = "(Optional) The name of an existing EC2 Key pair for SSH access to the EC2 Storage Gateway appliance"
  default     = null
}
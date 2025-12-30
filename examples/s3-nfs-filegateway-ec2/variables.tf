variable "aws_region" {
  type        = string
  description = "Region for AWS Resources"
  default     = "us-east-1"
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "The aws_region must be a valid AWS region (e.g., us-east-1, eu-west-2)."
  }
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPC CIDR block for the creation of example VPC and subnets"
  default     = "10.0.0.0/16"
  validation {
    condition     = can(cidrhost(var.vpc_cidr_block, 0))
    error_message = "The vpc_cidr_block must be a valid CIDR block (e.g., 10.0.0.0/16)."
  }
}

variable "client_ip_cidrs" {
  type        = string
  sensitive   = true
  description = "The IP addresses or CIDR block of clients that are allowed to access the file gateway. If there are multiple clients, please separate using commas. The value must contain valid CIDR blocks. Minimum 1 item. Maximum 100 items."
  default     = "10.0.0.0/16"
  validation {
    condition     = alltrue([for cidr in split(",", var.client_ip_cidrs) : can(cidrhost(trimspace(cidr), 0))])
    error_message = "All values in client_ip_cidrs must be valid CIDR blocks (e.g., 10.0.0.0/16)."
  }
}

variable "subnet-count" {
  type        = number
  description = "Number of subnets per type"
  default     = 1
  validation {
    condition     = var.subnet-count >= 1 && var.subnet-count <= 10
    error_message = "The subnet-count must be between 1 and 10."
  }
}

variable "ingress_cidr_blocks" {
  type        = string
  description = "The CIDR blocks to allow ingress into your File Gateway instance for NFS and SMB client access. For multiple CIDR blocks, please separate with comma"
  default     = "10.0.0.0/16"
  validation {
    condition     = alltrue([for cidr in split(",", var.ingress_cidr_blocks) : can(cidrhost(trimspace(cidr), 0))])
    error_message = "All values in ingress_cidr_blocks must be valid CIDR blocks (e.g., 10.0.0.0/16)."
  }
}

variable "ingress_cidr_block_activation" {
  type        = string
  description = "The CIDR block to allow ingress port 80 into your File Gateway instance for activation. For multiple CIDR blocks, please separate with comma"
  default     = "0.0.0.0/0"
  validation {
    condition     = alltrue([for cidr in split(",", var.ingress_cidr_block_activation) : can(cidrhost(trimspace(cidr), 0))])
    error_message = "All values in ingress_cidr_block_activation must be valid CIDR blocks (e.g., 0.0.0.0/0)."
  }
}

variable "ssh_public_key_path" {
  type        = string
  description = "(Optional) Absolute file path to the public key for the EC2 Key pair. If omitted, the EC2 key pair resource will not be created"
  default     = ""
}

variable "ssh_key_name" {
  type        = string
  description = "(Optional) The name of an existing EC2 Key pair for SSH access to the EC2 Storage Gateway"
  default     = null
}
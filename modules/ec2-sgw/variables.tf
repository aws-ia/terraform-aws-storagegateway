variable "availability_zone" {
  type        = string
  description = "Availability zone for the Gateway EC2 Instance"
}

variable "name" {
  default     = "aws-storage-gateway"
  type        = string
  description = "Name of the EC2 Storage Gateway instance"
}

variable "subnet_id" {
  type        = string
  description = "VPC Subnet ID to launch in the EC2 Instance"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID in which the Storage Gateway security group will be created in"
}

variable "security_group_id" {
  type        = string
  description = "Optionally provide an existing Security Group ID to associate with EC2 Storage Gateway appliance. Variable create_security_group should be set to false to use an existing Security Group"
  default     = null
}

variable "create_security_group" {
  type        = bool
  description = "Create a Security Group for the EC2 Storage Gateway appliance. If create_security_group=false, provide a valid security_group_id"
  default     = false
}

variable "ingress_cidr_blocks" {
  type        = string
  description = "The CIDR blocks to allow ingress into your File Gateway instance for NFS and SMB client access. For multiple CIDR blocks, please separate with comma"
  default     = "10.0.0.0/16"
}

variable "egress_cidr_blocks" {
  type        = string
  description = "The CIDR blocks for Gateway activation. Defaults to 0.0.0.0/0"
  default     = "0.0.0.0/0"
}

variable "ingress_cidr_block_activation" {
  type        = string
  description = "The CIDR block to allow ingress port 80 into your File Gateway instance for activation. For multiple CIDR blocks, please separate with comma"
}

variable "instance_type" {
  default     = "m5.xlarge"
  type        = string
  description = "The instance type to use for the Storage Gateway. Insatnce types supported are m5.xlarge is the minimum required for a small deployment. For a medium or a large deployment use m5.2xlarge or m5.4xlarge"
}

variable "timezone" {
  type        = string
  description = "Time zone for the gateway. The time zone is of the format GMT, GMT-hr:mm, or GMT+hr:mm.For example, GMT-4:00 indicates the time is 4 hours behind GMT. Avoid prefixing with 0"
  default     = "GMT"
  validation {
    condition     = can(regex("^GMT[+-](([1-9]|1[0-2]):([0-5][0-9]))|GMT$", var.timezone))
    error_message = "Time zone for the gateway. The time zone is of the format GMT, GMT-hr:mm, or GMT+hr:mm."
  }
}

variable "ssh_key_name" {
  type        = string
  description = "(Optional) The name of an existing EC2 Key pair for SSH access to the EC2 Storage Gateway appliance"
  default     = null
}

variable "root_block_device" {
  description = "Customize details about the root block device of the instance. See Block Devices in README.md for details"
  type        = map(any)
  default = {
    kms_key_id  = null
    disk_size   = 80
    volume_type = "gp3"
  }
}

variable "cache_block_device" {
  description = "Customize details about the additional block device of the instance. See Block Devices in README.md for details"
  type        = map(any)
  default = {
    kms_key_id  = null
    disk_size   = 150
    volume_type = "gp3"
  }
}
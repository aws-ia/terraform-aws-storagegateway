variable "aws_region" {
  type        = string
  description = "Region for AWS Resources"
  default     = ""
}

variable "availability_zone" {
  type        = string
  description = "Availability zone for the Gateway Ec2 Instance."
  default     = ""
}

variable "name" {
  default     = "aws-storage-gateway"
  type        = string
  description = "Name of the storage gateway instance that will be created in EC2"
}

variable "subnet_id" {
  type        = string
  description = "The ID of the Subnet which the EC2 Instance will be launched into."
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID of the VPC that the Storage Gateway Security Group will be created in."
}

variable "security_group_id" {
  type        = string
  description = "Optionally provide an existing Security Group ID to associate with EC2 Storage Gateway appliance. Variable create_security_group should be set to false to use exsiting Security Group."
  default     = ""
}

variable "create_security_group" {
  type        = bool
  description = "Create a Security Group for the EC2 Storage Gateway appliance. If create_security_group=false, provide a valid security_group_id"
  default     = true
}

variable "ingress_cidr_blocks" {
  type        = list(string)
  description = "The CIDR blocks to allow ingress into your File Gateway instance for NFS and SMB client access."
  default     = []
}

variable "ingress_cidr_block_activation" {
  type        = list(string)
  description = "The CIDR block to allow ingress port 80 into your File Gateway instance for activation."
  default     = ["0.0.0.0/0"]
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
  description = "SSH keypair for EC2"
  default     = "surampa"
}

variable "root_disk_size" {
  type        = number
  description = "The size of the drive in GiBs"
  default     = 80
}

variable "cache_size" {
  type        = number
  description = "The size of the drive in GiBs"
  default     = 150
}
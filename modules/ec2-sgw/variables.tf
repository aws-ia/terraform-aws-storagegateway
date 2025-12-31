variable "availability_zone" {
  type        = string
  description = "Availability zone for the Gateway EC2 Instance. If not specified, will be determined by the subnet."
  default     = null
}

variable "gateway_type" {
  type        = string
  description = "Type of the gateway. Valid options are FILE_S3, VTL, CACHED, STORED"
  default     = "FILE_S3"
  validation {
    condition     = contains(["FILE_S3", "VTL", "CACHED", "STORED"], var.gateway_type)
    error_message = "Incorrect gateway type. Valid options are FILE_S3, VTL, CACHED, STORED. Note: FILE_FSX_SMB is deprecated and not supported."
  }
}

variable "name" {
  default     = "aws-storage-gateway"
  type        = string
  description = "Name of the EC2 Storage Gateway instance"
}

variable "subnet_id" {
  type        = string
  description = "VPC Subnet ID to launch in the EC2 Instance"
  validation {
    condition     = can(regex("^subnet-[a-f0-9]{8,17}$", var.subnet_id))
    error_message = "The subnet_id must be a valid AWS subnet ID (e.g., subnet-0123456789abcdef0)."
  }
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID in which the Storage Gateway security group will be created in"
  validation {
    condition     = can(regex("^vpc-[a-f0-9]{8,17}$", var.vpc_id))
    error_message = "The vpc_id must be a valid AWS VPC ID (e.g., vpc-0123456789abcdef0)."
  }
}

variable "security_group_id" {
  type        = string
  description = "Optionally provide an existing Security Group ID to associate with EC2 Storage Gateway. Variable create_security_group should be set to false to use an existing Security Group"
  default     = null
}

variable "create_security_group" {
  type        = bool
  description = "Create a Security Group for the EC2 Storage Gateway. If create_security_group=false, provide a valid security_group_id"
  default     = false
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

variable "egress_cidr_blocks" {
  type        = string
  description = "The CIDR blocks for Gateway activation. Defaults to 0.0.0.0/0"
  default     = "0.0.0.0/0"
  validation {
    condition     = alltrue([for cidr in split(",", var.egress_cidr_blocks) : can(cidrhost(trimspace(cidr), 0))])
    error_message = "All values in egress_cidr_blocks must be valid CIDR blocks (e.g., 0.0.0.0/0)."
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

variable "instance_type" {
  default     = "m5.xlarge"
  type        = string
  description = "The instance type to use for the Storage Gateway. Instance types supported are m5.xlarge (minimum for small deployment), m5.2xlarge (medium), or m5.4xlarge (large). M6i variants are also supported."
  validation {
    condition     = contains(["m5.xlarge", "m5.2xlarge", "m5.4xlarge", "m6i.xlarge", "m6i.2xlarge", "m6i.4xlarge"], var.instance_type)
    error_message = "The instance_type must be one of: m5.xlarge, m5.2xlarge, m5.4xlarge, m6i.xlarge, m6i.2xlarge, m6i.4xlarge."
  }
}

variable "ssh_key_name" {
  type        = string
  description = "(Optional) The name of an existing EC2 Key pair for SSH access to the EC2 Storage Gateway"
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
  validation {
    condition     = try(tonumber(var.root_block_device["disk_size"]), 80) >= 80
    error_message = "The root_block_device disk_size must be at least 80 GB per AWS Storage Gateway requirements."
  }
  validation {
    condition     = try(contains(["gp2", "gp3", "io1", "io2", "st1", "sc1"], var.root_block_device["volume_type"]), true)
    error_message = "The root_block_device volume_type must be one of: gp2, gp3, io1, io2, st1, sc1."
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
  validation {
    condition     = try(tonumber(var.cache_block_device["disk_size"]), 150) >= 150
    error_message = "The cache_block_device disk_size must be at least 150 GB per AWS Storage Gateway requirements."
  }
  validation {
    condition     = try(contains(["gp2", "gp3", "io1", "io2", "st1", "sc1"], var.cache_block_device["volume_type"]), true)
    error_message = "The cache_block_device volume_type must be one of: gp2, gp3, io1, io2, st1, sc1."
  }
}
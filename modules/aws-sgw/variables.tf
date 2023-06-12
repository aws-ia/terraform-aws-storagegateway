variable "gateway_name" {
  type        = string
  description = "Storage Gateway Name"
}

variable "join_smb_domain" {
  type        = bool
  sensitive   = false
  default     = true
  description = "Setting for controlling whether to join the Storage gateway to an Active Directory (AD) domain for Server Message Block (SMB) file shares. Variables domain_controllers, domain_name, password and username should also be specified to join AD domain."
}

variable "domain_name" {
  type        = string
  sensitive   = true
  default     = ""
  description = "The name of the domain that you want the gateway to join"
}

variable "domain_username" {
  type        = string
  sensitive   = true
  default     = ""
  description = "The user name for the service account on your self-managed AD domain that SGW use to join to your AD domain"
}

variable "domain_password" {
  type        = string
  sensitive   = true
  default     = ""
  description = "The password for the service account on your self-managed AD domain that SGW will use to join to your AD domain"
}

variable "timeout_in_seconds" {
  type        = number
  sensitive   = false
  default     = -1
  description = "Specifies the time in seconds, in which the JoinDomain operation must complete. The default is 20 seconds."
}

variable "organizational_unit" {
  type        = string
  sensitive   = true
  default     = ""
  description = "The organizational unit (OU) is a container in an Active Directory that can hold users, groups, computers, and other OUs and this parameter specifies the OU that the gateway will join within the AD domain."
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

variable "gateway_type" {
  type        = string
  description = "Type of the gateway. Valid options are FILE_S3, FILE_FSX_SMB, VTL, CACHED, STORED"
  default     = "FILE_S3"
  validation {
    condition     = contains(["FILE_S3", "FILE_FSX_SMB", "VTL", "CACHED", "STORED"], var.gateway_type)
    error_message = "Incorrect gateway type. Valid options are FILE_S3, FILE_FSX_SMB, VTL, CACHED, STORED"
  }
}

variable "gateway_ip_address" {
  type        = string
  description = "IP Address of the SGW appliance in vSphere"
}

variable "disk_path" {
  default     = "/dev/sdb"
  type        = string
  description = "Path on the SGW appliance in vsphere where the cache disk resides on the OS"
}

variable "domain_controllers" {
  default     = []
  type        = list(any)
  sensitive   = true
  description = "List of IPv4 addresses, NetBIOS names, or host names of your domain server. If you need to specify the port number include it after the colon (“:”). For example, mydc.mydomain.com:389."
}

# VPC Endpoint related variables

variable "create_vpc_endpoint" {
  type        = bool
  description = "Create an Interface VPC endpoint for the EC2 Storage Gateway"
  default     = false
}

variable "vpc_id" {
  type        = string
  description = "VPC id for creating a VPC endpoint"
  default     = ""
}

variable "vpc_endpoint_subnet_ids" {
  type        = list(string)
  description = "Provide an existing subnet IDs to associate with the VPC Endpoint. By default all subnets will be used."
  default     = []
}

variable "create_vpc_endpoint_security_group" {
  type        = bool
  description = "Create a Security Group for the VPC Endpoint for EC2 Storage Gateway appliance. If create_security_group=false, provide a valid vpc_endpoint_security_group_id"
  default     = true
}

variable "vpc_endpoint_security_group_id" {
  type        = string
  description = "Optionally provide an existing Security Group ID to associate with the VPC Endpoint. Variable create_vpc_endpoint_security_group should be set to false to use exsiting Security Group."
  default     = ""
}

variable "ingress_cidr_block_activation" {
  type        = list(string)
  description = "The CIDR block to allow ingress port 80 into your File Gateway instance for activation."
  default     = ["0.0.0.0/0"]
}

variable "vpc_endpoint_private_dns_enabled" {
  type        = bool
  description = "Enable private DNS for VPC Endpoint"
  default     = true
}
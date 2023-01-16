variable "gateway_name" {
  type        = string
  description = "Storage Gateway Name"
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

variable "timeout_in_seconds" {
  type        = number
  sensitive   = false
  default     = -1
  description = "Specifies the time in seconds, in which the JoinDomain operation must complete. The default is 20 seconds."
}

variable "organizational_unit" {
  type        = string
  sensitive   = false
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
  description = "Comma separated list of domain controllers."
}

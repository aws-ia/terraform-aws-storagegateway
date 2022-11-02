variable "name" {
  description = "Name given resources"
  type        = string
  default     = "aws-IA"
}

variable "domain_name" {
  type        = string
  description = "Domain name"
}

variable "domain_username" {
  type        = string
  description = "The user name for the service account on your self-managed AD domain that SGW use to join to your AD domain"
}

variable "domain_password" {
  type        = string
  description = "The password for the service account on your self-managed AD domain that SGW will use to join to your AD domain"
}

variable "timezone" {
  type        = string
  description = "Time zone for the gateway. The time zone is of the format GMT, GMT-hr:mm, or GMT+hr:mm."
  default     = "GMT"
}

variable "gateway_type" {
  type        = string
  description = " Type of the gateway"
  default     = "FILE_S3"
}

variable "gateway_ip_address" {
  type        = string
  description = "IP Address of the SGW appliance in vSphere"
}

variable "disk_path" {
  default     = "/dev/sdb"
  type        = string
  description = "Path on the FSx appliance in vsphere where the cache disk resides on the OS"
}

variable "domain_controllers" {
  default     = []
  type        = list(any)
  description = "Comma separated list of domain controllers."
}

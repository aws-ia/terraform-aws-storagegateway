variable "aws_region" {
  type        = string
  description = "The name of the region you wish to deploy into"
  default     = ""
}

variable "ingress_cidr_blocks" {
  type        = list(string)
  description = "The CIDR blocks to allow ingress into your File Gateway instance for NFS and SMB client access."
  default     = []
}

# variable "availability_zone" {
#   type        = string
#   description = "Availability zone for the Gateway Ec2 Instance."
#   default     = ""
# }

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

variable "allow_unverified_ssl" {
  type        = bool
  description = "Boolean that can be set to true to disable SSL certificate verification."
  default     = false
}

variable "subnet-count" {
  type        = number
  description = "Number of sunbets per type"
  default     = 1
}
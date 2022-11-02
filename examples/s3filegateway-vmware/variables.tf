variable "region" {
  type        = string
  description = "The name of the region you wish to deploy into"
  default     = "us-east-1"
}
variable "domain_password" {
  type        = string
  description = "The password for the service account on your self-managed AD domain that SGW will use to join to your AD domain"
}

variable "domain_controllers" {
  type        = string
  description = "The IP address of the domain controllers"
}

variable "vsphere_password" {
  type        = string
  description = "The password for the vcenter server"
}

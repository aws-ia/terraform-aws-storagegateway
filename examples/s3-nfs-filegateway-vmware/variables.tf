variable "region" {
  type        = string
  description = "The name of the region you wish to deploy into"
  default     = "us-east-1"
}

variable "allow_unverified_ssl" {
  type        = bool
  description = "Boolean that can be set to true to disable SSL certificate verification."
  default     = false
}

variable "vsphere_server" {
  type        = string
  sensitive   = true
  description = "vSphere server IP address or fqdn"
}

variable "vsphere_user" {
  type        = string
  sensitive   = true
  description = "vSphere service account user name"
}

variable "vsphere_password" {
  type        = string
  sensitive   = true
  description = "The password for the vcenter server"
}

variable "datastore" {
  type        = string
  description = "Name of the vsphere datastore where the aws storage gateway will be deployed"
}

variable "cluster" {
  type        = string
  description = "Cluster where the aws storage gateway will be deployed"
}

variable "host" {
  type        = string
  description = "Target host used during deployment of the ova"
}

variable "datacenter" {
  type        = string
  description = "Name of the vsphere datacenter where the aws storage gateway will be deployed"
}

variable "network" {
  type        = string
  description = "Name of the vsphere port group that the aws storage gateway will use"
}
variable "client_list" {
  type        = list(any)
  sensitive   = true
  description = "The list of clients that are allowed to access the file gateway. The list must contain either valid IP addresses or valid CIDR blocks. Minimum 1 item. Maximum 100 items."
}
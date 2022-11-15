variable "region" {
  type        = string
  description = "The name of the region you wish to deploy into"
  default     = "us-east-1"
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

variable "domain_controllers" {
  default     = []
  type        = list(any)
  sensitive   = true
  description = "Comma separated list of domain controllers."
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
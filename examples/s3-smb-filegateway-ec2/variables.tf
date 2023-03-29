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

variable "allow_unverified_ssl" {
  type        = bool
  description = "Boolean that can be set to true to disable SSL certificate verification."
  default     = false
}

variable "subnet_id" {
  type        = string
  description = "The ID of the Subnet which the EC2 Instance will be launched into."
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID of the VPC that the Storage Gateway Security Group will be created in."
}

variable "ingress_cidr_blocks" {
  type        = list(any)
  description = "The CIDR blocks to allow ingress into your File Gateway instance. NOTE: Not allowing 0.0.0.0/0 during initial File Gateway creation will cause issues."
  sensitive   = true
}
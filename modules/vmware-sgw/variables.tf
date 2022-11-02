variable "cpus" {
  default     = "4"
  type        = string
  description = "Total number of vcpus that will be configured on the storage gateway"
}

variable "memory" {
  default     = "16384"
  type        = string
  description = "Total amount of memory that will be configured on the storage gateway. Specified in megabytes"
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

variable "os_size" {
  type        = string
  description = "Size of the OS disk of the appliance. Specified in gigabytes, default is the current appliance default. Likely doesn't need to be modified"
  default     = "80"
}

variable "network" {
  type        = string
  description = "Name of the vsphere port group that the aws storage gateway will use"
}

variable "name" {
  default     = "aws-storage-gateway"
  type        = string
  description = "Name of the storage gateway vm that will be created in vsphere"
}

variable "cache_size" {
  default     = "150"
  type        = string
  description = "Total size of the cache disk that will be added to the storage gateway. Specified in gigabytes"
}

variable "remote_ovf_url" {
  default     = "https://d28e23pnuuv0hr.cloudfront.net/aws-storage-gateway-latest.ova"
  type        = string
  description = "URL where the aws storage gateway ova is hosted."
}

variable "local_ovf_path" {
  default     = null
  type        = string
  description = "Location on the local machine where the aws storage gateway ova is hosted."
}

variable "provisioning_type" {
  default     = "thin"
  type        = string
  description = "Disk provisioning type for the vm and all attached disks"
}

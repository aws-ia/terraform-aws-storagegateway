variable "cpus" {
  default     = "4"
  type        = string
  description = "Total number of vcpus that will be configured on the storage gateway. 4 vCPU is the minimum required for a small deployment. For a medium or a large deployment increase to 8 or 16 vCPU "
}

variable "memory" {
  default     = "16384"
  type        = string
  description = "Total amount of memory that will be configured on the storage gateway. Specified in megabytes. 16384 MB is the minimum required for a small deployment. For a medium or a large deployment increase to 32768 or 65536"
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

variable "name" {
  default     = "aws-storage-gateway"
  type        = string
  description = "Name of the storage gateway vm that will be created in vsphere"
}

variable "cache_size" {
  default     = "150"
  type        = string
  description = "Size of the cache disk created by the OVA, in gigabytes. Only used when deployment_option = \"new-gateway\". Default is 150, can be increased up to 64000."
}

variable "os_size" {
  default     = "80"
  type        = string
  description = "Size of the OS disk in gigabytes. Default 80 (matches the v2 OVA's OS disk). Used by both \"new-gateway\" and \"migrate\" deployment options. For \"migrate\", set to the source gateway's OS disk size to match capacity."
}

variable "remote_ovf_url" {
  default     = "https://dd958of58tzpr.cloudfront.net/aws-storage-gateway-file-s3-gateway-v2-x86_64.ova"
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
  description = "Disk provisioning type for the OVF import. The v2 Storage Gateway OVA uses streamOptimized VMDKs, which can only land as \"thin\" during import. Disks may be inflated post-deploy if eager-zeroed thick is required."
  validation {
    condition     = var.provisioning_type == "thin"
    error_message = "The v2 Storage Gateway OVA only imports as \"thin\". Convert to thick post-deploy if needed."
  }
}

variable "deployment_option" {
  default     = "new-gateway"
  type        = string
  description = "OVF deployment option. \"new-gateway\" creates a fresh gateway with OS + cache disks (cache disk sized via cache_size). \"migrate\" creates only the OS disk - used as the replacement VM during a method-1 migration where cache disks are attached from the source VM."
  validation {
    condition     = contains(["new-gateway", "migrate"], var.deployment_option)
    error_message = "deployment_option must be either \"new-gateway\" or \"migrate\"."
  }
}

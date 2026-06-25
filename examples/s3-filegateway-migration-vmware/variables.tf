################################################################################
# Required Variables
################################################################################

variable "gateway_id" {
  type        = string
  description = "The Storage Gateway ID (e.g., sgw-12A3456B) of the gateway to migrate. The vSphere VM will be automatically discovered."
  validation {
    condition     = can(regex("^sgw-[A-Za-z0-9]{8,17}$", var.gateway_id))
    error_message = "The gateway_id must be a valid Storage Gateway ID (e.g., sgw-12A3456B)."
  }
}

################################################################################
# vSphere Connection Variables
################################################################################

variable "vsphere_server" {
  type        = string
  sensitive   = true
  description = "vSphere server IP address or FQDN"
}

variable "vsphere_user" {
  type        = string
  sensitive   = true
  description = "vSphere service account user name"
}

variable "vsphere_password" {
  type        = string
  sensitive   = true
  description = "The password for the vCenter server"
}

variable "allow_unverified_ssl" {
  type        = bool
  description = "Boolean that can be set to true to disable SSL certificate verification."
  default     = false
}

################################################################################
# vSphere Infrastructure Variables
################################################################################

variable "datacenter" {
  type        = string
  description = "Name of the vSphere datacenter where the new gateway VM will be deployed"
}

variable "datastore" {
  type        = string
  description = "Name of the vSphere datastore where the new gateway VM will be deployed"
}

variable "cluster" {
  type        = string
  description = "Cluster where the new gateway VM will be deployed"
}

variable "host" {
  type        = string
  description = "Target ESXi host used during deployment of the OVA"
}

variable "network" {
  type        = string
  description = "Name of the vSphere port group that the new gateway VM will use"
}

################################################################################
# Old Gateway VM Variables
################################################################################

variable "old_vm_name" {
  type        = string
  description = "Name of the existing gateway VM in vSphere to migrate from"
}

################################################################################
# Optional Variables
################################################################################

variable "gateway_type" {
  type        = string
  description = "Type of the gateway. Valid options are FILE_S3"
  default     = "FILE_S3"
  validation {
    condition     = var.gateway_type == "FILE_S3"
    error_message = "Incorrect gateway type. Valid option is FILE_S3."
  }
}

variable "new_vm_name" {
  type        = string
  description = "Name for the new gateway VM. If not specified, uses '<old_vm_name>-new'."
  default     = null
}

variable "cpus" {
  type        = string
  description = "Number of vCPUs for the new gateway VM. If not specified, matches the old VM."
  default     = null
}

variable "memory" {
  type        = string
  description = "Memory in MB for the new gateway VM. If not specified, matches the old VM."
  default     = null
}

variable "root_block_device" {
  type        = map(any)
  description = "Root (OS) disk configuration for the new gateway VM. By default the new VM's OS disk matches the source gateway VM's OS disk size so the migrated gateway has at least the same root capacity. Override per-attribute via root_block_device = { size = <gigabytes> }. Currently only the 'size' key is supported because the v2 OVA forces thin / non-eager-zeroed provisioning during import."
  default     = {}
  validation {
    condition     = try(tonumber(var.root_block_device.size), 80) >= 80
    error_message = "The root_block_device size must be at least 80 GB per AWS Storage Gateway requirements."
  }
}

variable "remote_ovf_url" {
  type        = string
  description = "URL where the AWS Storage Gateway OVA is hosted."
  default     = "https://dd958of58tzpr.cloudfront.net/aws-storage-gateway-file-s3-gateway-v2-x86_64.ova"
}

variable "local_ovf_path" {
  type        = string
  description = "Local path to the AWS Storage Gateway OVA file. Takes precedence over remote_ovf_url."
  default     = null
}

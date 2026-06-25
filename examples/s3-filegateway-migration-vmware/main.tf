################################################################################
# S3 File Gateway Migration Example - VMware (Method 1)
# Migrates an existing VMware gateway to a new VM while preserving cache disks
# and Gateway ID. Follows AWS Method 1:
# https://docs.aws.amazon.com/filegateway/latest/files3/migrate-data.html
################################################################################

################################################################################
# Data Sources - Gather information about existing gateway and vSphere
################################################################################

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# vSphere datacenter is needed to look up the existing VM. The other vSphere
# data sources are encapsulated in the vmware-sgw module.
data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

# Look up the existing gateway VM to read its current configuration and the
# list of attached VMDKs (used by the migration playbook to detach/reattach).
data "vsphere_virtual_machine" "old_sgw" {
  name          = var.old_vm_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

locals {
  new_vm_name = var.new_vm_name != null ? var.new_vm_name : "${var.old_vm_name}-new"

  # Use provided values or fall back to old VM configuration
  new_cpus   = var.cpus != null ? var.cpus : tostring(data.vsphere_virtual_machine.old_sgw.num_cpus)
  new_memory = var.memory != null ? var.memory : tostring(data.vsphere_virtual_machine.old_sgw.memory)

  # Source VM's OS disk. data...disks is ordered by SCSI unit; index 0 is OS.
  old_root_disk_size = data.vsphere_virtual_machine.old_sgw.disks[0].size

  # Build root block device config for the new VM. Defaults to the source
  # gateway's OS disk so the migrated gateway has at least the same root
  # capacity; per-attribute overrides via var.root_block_device. Mirrors the
  # EC2 migration example's root_block_device pattern.
  root_block_device = {
    size = try(tonumber(var.root_block_device.size), local.old_root_disk_size)
  }

  # Disks attached to the old VM. Index 0 is the OS disk, the rest are cache.
  old_vm_disks = data.vsphere_virtual_machine.old_sgw.disks
}

################################################################################
# New Gateway VM
#
# Deployed via the vmware-sgw module with deployment_option = "migrate". The
# OVA brings only the OS disk; cache disks (and the old VM's root disk) are
# attached by the Ansible migration playbook after this apply completes.
################################################################################

module "new_sgw" {
  source = "../../modules/vmware-sgw"

  name              = local.new_vm_name
  datacenter        = var.datacenter
  datastore         = var.datastore
  cluster           = var.cluster
  host              = var.host
  network           = var.network
  cpus              = local.new_cpus
  memory            = local.new_memory
  os_size           = tostring(local.root_block_device.size)
  remote_ovf_url    = var.remote_ovf_url
  local_ovf_path    = var.local_ovf_path
  deployment_option = "migrate"
}

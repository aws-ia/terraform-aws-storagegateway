# target datacenter where the vm will be placed
data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

# target datastore where the vm will be placed
data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

# target cluster root resource pool where the vm will be placed
data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

# target host that will be used to deploy the ova on
data "vsphere_host" "host" {
  name          = var.host
  datacenter_id = data.vsphere_datacenter.dc.id
}

# vsphere port group that will be used for the Gateway
data "vsphere_network" "network" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Read OVA properties to get correct guest_id, firmware, and disk layout for
# the selected deployment_option ("new-gateway" creates OS + cache disks,
# "migrate" creates OS disk only - cache disks are attached post-deploy).
data "vsphere_ovf_vm_template" "sgw" {
  name              = var.name
  resource_pool_id  = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id      = data.vsphere_datastore.datastore.id
  host_system_id    = data.vsphere_host.host.id
  local_ovf_path    = var.local_ovf_path
  remote_ovf_url    = var.local_ovf_path == null ? var.remote_ovf_url : null
  disk_provisioning = var.provisioning_type
  deployment_option = var.deployment_option
  ovf_network_map = {
    "VM Network" = data.vsphere_network.network.id
  }
}

locals {
  is_new_gateway = var.deployment_option == "new-gateway"
}

################################################################################
# vSphere VM - "new-gateway" deployment option
#
# Used for fresh Storage Gateway deployments. The OVA brings the OS disk and
# the cache disk; inline disk blocks below override the OVA disk sizes via
# var.os_size and var.cache_size.
################################################################################

resource "vsphere_virtual_machine" "vm" {
  count = local.is_new_gateway ? 1 : 0

  host_system_id      = data.vsphere_host.host.id
  resource_pool_id    = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id        = data.vsphere_datastore.datastore.id
  datacenter_id       = data.vsphere_datacenter.dc.id
  name                = var.name
  num_cpus            = var.cpus
  memory              = var.memory
  guest_id            = data.vsphere_ovf_vm_template.sgw.guest_id
  firmware            = data.vsphere_ovf_vm_template.sgw.firmware
  sync_time_with_host = true

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  # OS disk - sized via var.os_size (default 80, matches the OVA). Declared
  # inline so callers can resize the OS disk at import time.
  disk {
    label            = "os"
    unit_number      = 0
    size             = var.os_size
    thin_provisioned = true
    eagerly_scrub    = false
  }

  # Cache disk - sized via var.cache_size. The OVF descriptor declares the
  # cache disk's capacity as ${cache.size}; the inline disk block overrides
  # that on import.
  disk {
    label            = "cache"
    unit_number      = 1
    size             = var.cache_size
    thin_provisioned = true
    eagerly_scrub    = false
  }

  ovf_deploy {
    local_ovf_path    = var.local_ovf_path
    remote_ovf_url    = var.local_ovf_path == null ? var.remote_ovf_url : null
    disk_provisioning = var.provisioning_type
    deployment_option = var.deployment_option
    ovf_network_map   = data.vsphere_ovf_vm_template.sgw.ovf_network_map
  }

  lifecycle {
    ignore_changes = [
      host_system_id,
      annotation,
      disk[0].io_share_count,
      disk[0].thin_provisioned,
      disk[1].io_share_count,
      disk[1].thin_provisioned,
    ]
  }
}

################################################################################
# vSphere VM - "migrate" deployment option
#
# Used as the replacement VM in a method-1 Storage Gateway migration. The OVA
# brings only the OS disk; cache disks (and the old VM's root disk) are
# detached from the source VM and attached to this VM by the migration
# playbook.
################################################################################

resource "vsphere_virtual_machine" "vm_migrate" {
  count = local.is_new_gateway ? 0 : 1

  host_system_id      = data.vsphere_host.host.id
  resource_pool_id    = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id        = data.vsphere_datastore.datastore.id
  datacenter_id       = data.vsphere_datacenter.dc.id
  name                = var.name
  num_cpus            = var.cpus
  memory              = var.memory
  guest_id            = data.vsphere_ovf_vm_template.sgw.guest_id
  firmware            = data.vsphere_ovf_vm_template.sgw.firmware
  sync_time_with_host = true

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  # OS disk - sized via var.os_size. For migrate, the example sets this to
  # the source gateway's OS disk size so the migrated VM has at least the
  # same root capacity. Cache and old-root VMDKs are attached to this VM
  # out-of-band by the Ansible migration playbook.
  disk {
    label            = "os"
    unit_number      = 0
    size             = var.os_size
    thin_provisioned = true
    eagerly_scrub    = false
  }

  ovf_deploy {
    local_ovf_path    = var.local_ovf_path
    remote_ovf_url    = var.local_ovf_path == null ? var.remote_ovf_url : null
    disk_provisioning = var.provisioning_type
    deployment_option = var.deployment_option
    ovf_network_map   = data.vsphere_ovf_vm_template.sgw.ovf_network_map
  }

  lifecycle {
    ignore_changes = [
      host_system_id,
      annotation,
      # The migration playbook hot-adds cache and old-root VMDKs at SCSI 0:1+
      # after this resource is created, so ignore the entire disk list here.
      # The OS disk size is set on initial create and is not expected to drift.
      disk,
    ]
  }
}

# Look up the deployed VM to expose its guest IP address as a module output.
data "vsphere_virtual_machine" "aws_sg" {
  name          = var.name
  datacenter_id = data.vsphere_datacenter.dc.id
  depends_on = [
    vsphere_virtual_machine.vm,
    vsphere_virtual_machine.vm_migrate,
  ]
}

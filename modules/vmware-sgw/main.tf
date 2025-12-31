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

# Read OVA properties to get correct guest_id and other settings
data "vsphere_ovf_vm_template" "sgw" {
  name              = var.name
  resource_pool_id  = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id      = data.vsphere_datastore.datastore.id
  host_system_id    = data.vsphere_host.host.id
  local_ovf_path    = var.local_ovf_path
  remote_ovf_url    = var.local_ovf_path == null ? var.remote_ovf_url : null
  disk_provisioning = var.provisioning_type
  ovf_network_map = {
    "VM Network" = data.vsphere_network.network.id
  }
}

################################################################################
# Creating vSphere virtual machine
################################################################################

resource "vsphere_virtual_machine" "vm" {
  host_system_id             = data.vsphere_host.host.id
  resource_pool_id           = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id               = data.vsphere_datastore.datastore.id
  datacenter_id              = data.vsphere_datacenter.dc.id
  name                       = var.name
  num_cpus                   = var.cpus
  memory                     = var.memory
  guest_id                   = data.vsphere_ovf_vm_template.sgw.guest_id
  firmware                   = data.vsphere_ovf_vm_template.sgw.firmware
  wait_for_guest_net_timeout = 1
  sync_time_with_host        = true


  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label            = "os"
    unit_number      = 0
    size             = var.os_size
    thin_provisioned = false
    eagerly_scrub    = false
  }

  disk {
    label            = "cache"
    unit_number      = 1
    size             = var.cache_size
    thin_provisioned = false
    eagerly_scrub    = false
  }

  ovf_deploy {
    local_ovf_path       = var.local_ovf_path != null ? var.local_ovf_path : null
    remote_ovf_url       = var.remote_ovf_url != null && var.local_ovf_path == null ? var.remote_ovf_url : null
    disk_provisioning    = data.vsphere_ovf_vm_template.sgw.disk_provisioning
    ovf_network_map      = data.vsphere_ovf_vm_template.sgw.ovf_network_map
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


# data block to output the ip of the VM
data "vsphere_virtual_machine" "aws_sg" {
  name          = var.name
  datacenter_id = data.vsphere_datacenter.dc.id
  depends_on = [
    vsphere_virtual_machine.vm
  ]
}

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

# vsphere port group that will be used for the appliance
data "vsphere_network" "network" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.dc.id
}

# configuration values of the appliance that will be deployed
resource "vsphere_virtual_machine" "vm" {
  host_system_id             = data.vsphere_host.host.id
  resource_pool_id           = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id               = data.vsphere_datastore.datastore.id
  datacenter_id              = data.vsphere_datacenter.dc.id
  name                       = var.name
  num_cpus                   = var.cpus
  memory                     = var.memory
  wait_for_guest_net_timeout = 1
  sync_time_with_host        = true


  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label       = "os"
    unit_number = 0
    size        = var.os_size
  }

  disk {
    label       = "cache"
    unit_number = 1
    size        = var.cache_size
  }

  ovf_deploy {
    local_ovf_path    = var.local_ovf_path != null ? var.local_ovf_path : null
    remote_ovf_url    = var.remote_ovf_url != null && var.local_ovf_path == null ? var.remote_ovf_url : null
    disk_provisioning = var.provisioning_type
    ovf_network_map = {
      "eth0" = data.vsphere_network.network.id
    }
  }

  lifecycle {
    ignore_changes = [
      annotation,
      disk[0].io_share_count,
      disk[1].io_share_count
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

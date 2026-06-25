output "vm_ip" {
  value       = data.vsphere_virtual_machine.aws_sg.guest_ip_addresses[0]
  description = "IP address of the storage gateway VM"
}

output "vm_name" {
  value       = data.vsphere_virtual_machine.aws_sg.name
  description = "Name of the storage gateway VM in vSphere"
}

output "vm_id" {
  value       = data.vsphere_virtual_machine.aws_sg.id
  description = "Managed Object ID of the storage gateway VM"
}

output "deployment_option" {
  value       = var.deployment_option
  description = "OVF deployment option used to create the VM (\"new-gateway\" or \"migrate\")"
}

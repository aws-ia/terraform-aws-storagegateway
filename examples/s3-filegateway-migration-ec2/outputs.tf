################################################################################
# Migration Outputs
################################################################################

output "migration_summary" {
  description = "Summary of the migration process. Marked sensitive because it includes fields derived from data.aws_instance.old_sgw.root_block_device, which the AWS provider treats as sensitive. Use `terraform output -json migration_summary` to view."
  sensitive   = true
  value = {
    gateway_id         = var.gateway_id
    old_instance_id    = data.aws_instance.old_sgw.id
    new_instance_id    = module.new_sgw.instance_id
    old_instance_type  = data.aws_instance.old_sgw.instance_type
    new_instance_type  = local.new_instance_type
    old_root_disk_size = local.old_root_disk.volume_size
    new_root_disk_size = local.root_block_device.disk_size
    root_disk_type     = local.root_block_device.volume_type
    vpc_id             = local.vpc_id
    subnet_id          = data.aws_instance.old_sgw.subnet_id
    availability_zone  = data.aws_instance.old_sgw.availability_zone
    cache_volumes      = data.aws_ebs_volumes.cache_volumes.ids
  }
}

output "new_gateway_instance_id" {
  description = "The EC2 instance ID of the new Storage Gateway"
  value       = module.new_sgw.instance_id
}

output "new_gateway_private_ip" {
  description = "The private IP address of the new Storage Gateway"
  value       = module.new_sgw.private_ip
}

output "new_gateway_public_ip" {
  description = "The public IP address of the new Storage Gateway"
  value       = module.new_sgw.instance_public_ip
  sensitive   = true
}

output "old_instance_id" {
  description = "The EC2 instance ID of the old Storage Gateway"
  value       = data.aws_instance.old_sgw.id
}

output "gateway_id" {
  description = "The Storage Gateway ID being migrated"
  value       = var.gateway_id
}

output "aws_region" {
  description = "The AWS region where the migration is taking place"
  value       = regex("^([a-z]+-[a-z]+-[0-9]+)", data.aws_instance.old_sgw.availability_zone)
}

output "migration_url" {
  description = "URL to initiate the gateway migration process"
  value       = "http://${module.new_sgw.private_ip}/migrate?gatewayId=${var.gateway_id}"
}

output "next_steps" {
  description = "Next steps to complete the migration"
  value       = <<-EOT
    Migration Infrastructure Provisioned Successfully!
    
    AUTOMATED MIGRATION (Recommended):
    ===================================
    Run the Ansible playbook to automate the migration:
    
      cd ansible/
      chmod +x run-migration.sh
      ./run-migration.sh
    
    The playbook will automatically:
    - Stop old gateway instance
    - Detach and reattach volumes from old gateway instance to new gateway instance 
    - Trigger the migration using URL
    - Detach the old root disk after a successful migration
    - Re-Join the Gateway to the AD domain if previously joined. 
    - Complete the migration 
  EOT
}

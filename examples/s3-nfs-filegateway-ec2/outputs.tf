output "storage_gateway_id" {
  description = "Storage Gateway ID"
  value       = module.sgw.storage_gateway.gateway_id
}

output "storage_gateway_arn" {
  description = "Storage Gateway ARN"
  value       = module.sgw.storage_gateway.arn
}

output "nfs_file_share_arn" {
  description = "NFS File Share ARN"
  value       = module.nfs_share.nfs_share_arn
}

output "nfs_file_share_path" {
  description = "NFS File Share path"
  value       = module.nfs_share.nfs_share_path
}

output "s3_bucket_name" {
  description = "S3 bucket name for the file gateway"
  value       = module.s3_bucket.s3_bucket_id
}

output "gateway_public_ip" {
  description = "Public IP of the Storage Gateway EC2 instance"
  value       = module.ec2_sgw.public_ip
  sensitive   = true
}

output "gateway_private_ip" {
  description = "Private IP of the Storage Gateway EC2 instance"
  value       = module.ec2_sgw.private_ip
}

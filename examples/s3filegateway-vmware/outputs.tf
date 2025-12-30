output "storage_gateway_id" {
  value       = module.sgw.storage_gateway.gateway_id
  description = "Storage Gateway ID"
  sensitive   = true
}

output "s3_bucket_id" {
  value       = module.s3_bucket.s3_bucket_id
  description = "The name of the bucket."
}

output "s3_bucket_arn" {
  value       = module.s3_bucket.s3_bucket_arn
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname."
}

output "smb_share_arn" {
  value       = module.smb_share.smb_share_arn
  description = "ARN of the created SMB share"
}

output "smb_share_path" {
  value       = module.smb_share.smb_share_path
  description = "SMB share mountpoint path"
}
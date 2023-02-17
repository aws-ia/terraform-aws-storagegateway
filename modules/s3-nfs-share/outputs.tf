output "nfs_share_arn" {
  value       = aws_storagegateway_nfs_file_share.nfsshare.arn
  description = "The ARN of the created NFS File Share."
}

output "nfs_share_path" {
  value       = aws_storagegateway_nfs_file_share.nfsshare.path
  description = "The path of the created NFS File Share."
}
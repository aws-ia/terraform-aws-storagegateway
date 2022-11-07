output "smb_share_arn" {
  value       = aws_storagegateway_smb_file_share.smbshare.arn
  description = "The ARN of the created SMB File Share."
}

output "smb_share_path" {
  value       = aws_storagegateway_smb_file_share.smbshare.path
  description = "The path of the created SMB File Share."
}
################################################################################
# SMB File Share
################################################################################


resource "aws_storagegateway_smb_file_share" "smbshare" {
  file_share_name       = var.share_name
  authentication        = "ActiveDirectory"
  gateway_arn           = var.gateway_arn
  location_arn          = var.bucket_arn
  default_storage_class = var.storage_class
  role_arn              = var.role_arn
  admin_user_list       = var.admin_user_list
  smb_acl_enabled       = true
  audit_destination_arn = var.log_group_arn
  cache_attributes {
    cache_stale_timeout_in_seconds = 3600
  }
  tags = {
    Environment = "dev"
    Application = "serviceA"
  }
}
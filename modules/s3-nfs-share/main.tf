################################################################################
# NFS File Share
################################################################################

resource "aws_storagegateway_nfs_file_share" "nfsshare" {
  file_share_name       = var.share_name
  client_list           = var.client_list
  gateway_arn           = var.gateway_arn
  location_arn          = var.bucket_arn
  role_arn              = var.role_arn
  default_storage_class = var.storage_class
  audit_destination_arn = var.log_group_arn
  kms_encrypted         = var.kms_encrypted
  kms_key_arn           = var.kms_encrypted ? var.kms_key_arn : null

  nfs_file_share_defaults {
    directory_mode = var.directory_mode
    file_mode      = var.file_mode
    group_id       = var.group_id
    owner_id       = var.owner_id
  }

  cache_attributes {
    cache_stale_timeout_in_seconds = var.cache_timout
  }

  tags = var.tags

}

################################################################################
# Storage Gateway
################################################################################

locals {

  # Check whether all SMB Active Directory Settings are present
  join_smb_domain_true     = var.join_smb_domain == true
  domain_controllers_exist = length(var.domain_controllers) > 0
  domain_name_exists       = length(var.domain_name) > 0
  domain_password_exists   = length(var.domain_password) > 0
  domain_username_exists   = length(var.domain_username) > 0

  create_smb_active_directory_settings = (local.join_smb_domain_true &&
    local.domain_controllers_exist &&
    local.domain_name_exists &&
    local.domain_password_exists &&
  local.domain_username_exists)

}

resource "aws_storagegateway_gateway" "mysgw" {
  gateway_ip_address = var.gateway_ip_address
  gateway_name       = var.gateway_name
  gateway_timezone   = var.timezone
  gateway_type       = var.gateway_type

  dynamic "smb_active_directory_settings" {
    for_each = local.create_smb_active_directory_settings == true ? [1] : []

    content {

      # Required inputs
      domain_name = var.domain_name
      password    = var.domain_password
      username    = var.domain_username

      # Optional inputs
      domain_controllers  = var.domain_controllers
      timeout_in_seconds  = var.timeout_in_seconds >= 0 ? var.timeout_in_seconds : null
      organizational_unit = length(var.organizational_unit) > 0 ? var.organizational_unit : null
    }
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_storagegateway_cache" "sgw" {
  disk_id     = data.aws_storagegateway_local_disk.sgw.disk_id
  gateway_arn = aws_storagegateway_gateway.mysgw.arn

  lifecycle {
    ignore_changes = [
      disk_id
    ]
  }
}

data "aws_storagegateway_local_disk" "sgw" {
  gateway_arn = aws_storagegateway_gateway.mysgw.arn
  disk_path   = var.disk_path
}



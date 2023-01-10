################################################################################
# Storage Gateway
################################################################################

locals {
  create_smb_active_directory_settings = (var.join_smb_domain == true && length(var.domain_controllers) > 0 && length(var.domain_name) > 0 && length(var.domain_password) > 0 && length(var.domain_username) > 0)
}


resource "aws_storagegateway_gateway" "mysgw" {
  gateway_ip_address = var.gateway_ip_address
  gateway_name       = var.gateway_name
  gateway_timezone   = var.timezone
  gateway_type       = var.gateway_type


  dynamic "smb_active_directory_settings" {
    for_each = local.create_smb_active_directory_settings == true ? [1] : []

    content {

      domain_name        = var.domain_name
      password           = var.domain_password
      username           = var.domain_username
      domain_controllers = var.domain_controllers

      timeout_in_seconds  = var.timeout_in_seconds
      organizational_unit = var.organizational_unit

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



################################################################################
# Storage Gateway
################################################################################

resource "aws_storagegateway_gateway" "mysgw" {
  gateway_ip_address = var.gateway_ip_address
  gateway_name       = var.gateway_name
  gateway_timezone   = var.timezone
  gateway_type       = var.gateway_type

  smb_active_directory_settings {
    domain_name        = var.domain_name
    password           = var.domain_password
    username           = var.domain_username
    domain_controllers = var.domain_controllers
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



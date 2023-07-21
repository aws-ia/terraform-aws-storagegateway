################################################################################
# Storage Gateway
################################################################################

locals {
  create_smb_active_directory_settings = (var.join_smb_domain == true && length(var.domain_controllers) > 0 && length(var.domain_name) > 0 && length(var.domain_password) > 0 && length(var.domain_username) > 0)
}

resource "aws_storagegateway_gateway" "mysgw" {
  gateway_ip_address   = var.gateway_ip_address
  gateway_name         = var.gateway_name
  gateway_timezone     = var.timezone
  gateway_type         = var.gateway_type
  gateway_vpc_endpoint = var.create_vpc_endpoint ? aws_vpc_endpoint.sgw_vpce["sgw_vpce"].dns_entry[0].dns_name : var.gateway_vpc_endpoint

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
  disk_node   = var.disk_node
  disk_path   = var.disk_path
}

##########################
## Create VPC Endpoint
##########################

data "aws_region" "current" {}

resource "aws_vpc_endpoint" "sgw_vpce" {

  for_each = var.create_vpc_endpoint ? toset(["sgw_vpce"]) : toset([])

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.storagegateway"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    var.create_vpc_endpoint_security_group ? aws_security_group.vpce_sg["vpce_sg"].id : var.vpc_endpoint_security_group_id
  ]

  subnet_ids = var.vpc_endpoint_subnet_ids

  private_dns_enabled = var.vpc_endpoint_private_dns_enabled

  tags = {
    Name = "storage-gateway-endpoint"
  }

  lifecycle {
    # VPC Subnet IDs must be non empty
    precondition {
      condition     = try(length(var.vpc_endpoint_subnet_ids[0]) > 7, false)
      error_message = "Variable vpc_endpoint_subnet_ids must contain at least one valid subnet to create VPC Endpoint Security Group"
    }
  }

}



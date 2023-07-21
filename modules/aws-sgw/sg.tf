# Security group for VPC Endpoint
resource "aws_security_group" "vpce_sg" {

  for_each = (var.create_vpc_endpoint && var.create_vpc_endpoint_security_group) ? toset(["vpce_sg"]) : toset([])

  lifecycle {
    # The gateway_private_ip_address must be valid"
    precondition {
      condition     = can(cidrnetmask("${var.gateway_private_ip_address}/32"))
      error_message = "Variable gateway_private_ip_address must be a valid IPv4 address to create VPC Endpoint Security Group"
    }
  }

  description = "Security group with custom ports open Storage Gateway VPC Endpoint connectivity"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "vpce_443" {
  for_each          = (var.create_vpc_endpoint && var.create_vpc_endpoint_security_group) ? toset(["vpce_443"]) : toset([])
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  description       = "VPC Endpoint rule HTTPS"
  cidr_blocks       = ["${var.gateway_private_ip_address}/32"]
  security_group_id = aws_security_group.vpce_sg["vpce_sg"].id
}

resource "aws_security_group_rule" "vpce_dynamic" {
  for_each          = (var.create_vpc_endpoint && var.create_vpc_endpoint_security_group) ? toset(["vpce_dynamic"]) : toset([])
  type              = "ingress"
  from_port         = 1026
  to_port           = 1028
  protocol          = "tcp"
  description       = "VPC Endpoint rules"
  cidr_blocks       = ["${var.gateway_private_ip_address}/32"]
  security_group_id = aws_security_group.vpce_sg["vpce_sg"].id
}

resource "aws_security_group_rule" "vpce_1031" {
  for_each          = (var.create_vpc_endpoint && var.create_vpc_endpoint_security_group) ? toset(["vpce_1031"]) : toset([])
  type              = "ingress"
  from_port         = 1031
  to_port           = 1031
  protocol          = "tcp"
  description       = "VPC Endpoint rules"
  cidr_blocks       = ["${var.gateway_private_ip_address}/32"]
  security_group_id = aws_security_group.vpce_sg["vpce_sg"].id
}

resource "aws_security_group_rule" "vpce_2222" {
  for_each          = (var.create_vpc_endpoint && var.create_vpc_endpoint_security_group) ? toset(["vpce_2222"]) : toset([])
  type              = "ingress"
  from_port         = 2222
  to_port           = 2222
  protocol          = "tcp"
  description       = "VPC Endpoint rules"
  cidr_blocks       = ["${var.gateway_private_ip_address}/32"]
  security_group_id = aws_security_group.vpce_sg["vpce_sg"].id
}

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

  ingress {

    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "VPC Endpoint rule"
    cidr_blocks = ["${var.gateway_private_ip_address}/32"]
  }
  ingress {
    from_port   = 1026
    to_port     = 1026
    protocol    = "tcp"
    description = "VPC Endpoint rule"
    cidr_blocks = ["${var.gateway_private_ip_address}/32"]
  }
  ingress {
    from_port   = 1027
    to_port     = 1027
    protocol    = "tcp"
    description = "VPC Endpoint rule"
    cidr_blocks = ["${var.gateway_private_ip_address}/32"]
  }
  ingress {
    from_port   = 1028
    to_port     = 1028
    protocol    = "tcp"
    description = "VPC Endpoint rule"
    cidr_blocks = ["${var.gateway_private_ip_address}/32"]
  }
  ingress {
    from_port   = 1031
    to_port     = 1031
    protocol    = "tcp"
    description = "VPC Endpoint rule"
    cidr_blocks = ["${var.gateway_private_ip_address}/32"]
  }

  ingress {
    from_port   = 2222
    to_port     = 2222
    protocol    = "tcp"
    description = "VPC Endpoint rule"
    cidr_blocks = ["${var.gateway_private_ip_address}/32"]
  }
  #outbound connections for VPC endpoint to reach to AWS services
  #tfsec:ignore:aws-ec2-no-public-egress-sgr
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "VPC Endpoint rule"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

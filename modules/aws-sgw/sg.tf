# Security group for VPC Endpoint
resource "aws_security_group" "vpce_sg" {

  for_each = (var.create_vpc_endpoint && var.create_vpc_endpoint_security_group) ? toset(["vpce_sg"]) : toset([])

  description = "Security group with custom ports open Storage Gateway VPC Endpoint connectivity"
  vpc_id      = var.vpc_id

  ingress {

    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "VPC Endpoint rule"
    cidr_blocks = var.ingress_cidr_block_activation
  }
  ingress {
    from_port   = 1026
    to_port     = 1026
    protocol    = "tcp"
    description = "VPC Endpoint rule"
    cidr_blocks = var.ingress_cidr_block_activation
  }
  ingress {
    from_port   = 1027
    to_port     = 1027
    protocol    = "tcp"
    description = "VPC Endpoint rule"
    cidr_blocks = var.ingress_cidr_block_activation
  }
  ingress {
    from_port   = 1028
    to_port     = 1028
    protocol    = "tcp"
    description = "VPC Endpoint rule"
    cidr_blocks = var.ingress_cidr_block_activation
  }
  ingress {
    from_port   = 2222
    to_port     = 2222
    protocol    = "tcp"
    description = "VPC Endpoint rule"
    cidr_blocks = var.ingress_cidr_block_activation
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

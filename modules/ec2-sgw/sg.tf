module "ec2_sg" {
  count  = var.create_security_group ? 1 : 0
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.name}.security-group"
  description = "Security group for user-service with custom ports open within VPC, and PostgreSQL publicly open"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = [var.ingress_cidr_blocks]
  ingress_rules       = ["ssh-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP required only for activation purposes. The port is closed after activation."
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 2049
      to_port     = 2049
      protocol    = "tcp"
      description = "NFS-TCP"
      cidr_blocks = var.ingress_cidr_blocks
    },
    {
      from_port   = 111
      to_port     = 111
      protocol    = "tcp"
      description = "NFS"
      cidr_blocks = var.ingress_cidr_blocks
    },
    {
      from_port   = 20048
      to_port     = 20048
      protocol    = "tcp"
      description = "NFSv3-TCP"
      cidr_blocks = var.ingress_cidr_blocks
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS"
      cidr_blocks = var.ingress_cidr_blocks
    },
    {
      from_port   = 53
      to_port     = 53
      protocol    = "tcp"
      description = "DNS-TCP"
      cidr_blocks = var.ingress_cidr_blocks
    },
    {
      from_port   = 123
      to_port     = 123
      protocol    = "udp"
      description = "NTP"
      cidr_blocks = var.ingress_cidr_blocks
    },
    {
      from_port   = 445
      to_port     = 445
      protocol    = "tcp"
      description = "SMB"
      cidr_blocks = var.ingress_cidr_blocks
    }
  ]
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
}

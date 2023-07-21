locals {
  ingress_cidr_blocks_list           = split(",", var.ingress_cidr_blocks)
  egress_cidr_blocks_list            = split(",", var.egress_cidr_blocks)
  ingress_cidr_block_activation_list = split(",", var.ingress_cidr_block_activation)
}

resource "aws_security_group" "ec2_sg" {

  for_each = var.create_security_group == true ? toset(["ec2_sg"]) : toset([])

  name        = "${var.name}.security-group"
  description = "Security group with custom ports open within VPC for client connectivity and communication with AWS."
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "http" {
  for_each          = var.create_security_group == true ? toset(["http"]) : toset([])
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  description       = "HTTP required only for activation purposes. The port is closed after activation."
  cidr_blocks       = local.ingress_cidr_block_activation_list
  security_group_id = aws_security_group.ec2_sg["ec2_sg"].id
}

resource "aws_security_group_rule" "nfs_tcp" {
  for_each          = var.create_security_group == true ? toset(["nfs_tcp"]) : toset([])
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  description       = "NFS-TCP"
  cidr_blocks       = local.ingress_cidr_blocks_list
  security_group_id = aws_security_group.ec2_sg["ec2_sg"].id
}

resource "aws_security_group_rule" "nfs_udp" {
  for_each          = var.create_security_group == true ? toset(["nfs_udp"]) : toset([])
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "udp"
  description       = "NFS-UDP"
  cidr_blocks       = local.ingress_cidr_blocks_list
  security_group_id = aws_security_group.ec2_sg["ec2_sg"].id
}

resource "aws_security_group_rule" "nfs_portmapper_tcp" {
  for_each          = var.create_security_group == true ? toset(["nfs_portmapper_tcp"]) : toset([])
  type              = "ingress"
  from_port         = 111
  to_port           = 111
  protocol          = "tcp"
  description       = "NFS-portmapper-TCP"
  cidr_blocks       = local.ingress_cidr_blocks_list
  security_group_id = aws_security_group.ec2_sg["ec2_sg"].id
}

resource "aws_security_group_rule" "nfs_portmap_udp" {
  for_each          = var.create_security_group == true ? toset(["nfs_portmap_udp"]) : toset([])
  type              = "ingress"
  from_port         = 111
  to_port           = 111
  protocol          = "udp"
  description       = "NFS-portmapper-UDP"
  cidr_blocks       = local.ingress_cidr_blocks_list
  security_group_id = aws_security_group.ec2_sg["ec2_sg"].id
}


resource "aws_security_group_rule" "nfs_v3_tcp" {
  for_each          = var.create_security_group == true ? toset(["nfs_v3_tcp"]) : toset([])
  type              = "ingress"
  from_port         = 20048
  to_port           = 20048
  protocol          = "tcp"
  description       = "NFSv3-TCP"
  cidr_blocks       = local.ingress_cidr_blocks_list
  security_group_id = aws_security_group.ec2_sg["ec2_sg"].id
}

resource "aws_security_group_rule" "nfs_v3_udp" {
  for_each          = var.create_security_group == true ? toset(["nfs_v3_udp"]) : toset([])
  type              = "ingress"
  from_port         = 20048
  to_port           = 20048
  protocol          = "UDP"
  description       = "NFSv3-UDP"
  cidr_blocks       = local.ingress_cidr_blocks_list
  security_group_id = aws_security_group.ec2_sg["ec2_sg"].id
}

resource "aws_security_group_rule" "https" {
  for_each          = var.create_security_group == true ? toset(["https"]) : toset([])
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  description       = "HTTPS"
  cidr_blocks       = local.ingress_cidr_blocks_list
  security_group_id = aws_security_group.ec2_sg["ec2_sg"].id
}

resource "aws_security_group_rule" "dns_tcp" {
  for_each          = var.create_security_group == true ? toset(["dns_tcp"]) : toset([])
  type              = "ingress"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  description       = "DNS-TCP"
  cidr_blocks       = local.ingress_cidr_blocks_list
  security_group_id = aws_security_group.ec2_sg["ec2_sg"].id
}

resource "aws_security_group_rule" "ntp_udp" {
  for_each          = var.create_security_group == true ? toset(["ntp_udp"]) : toset([])
  type              = "ingress"
  from_port         = 123
  to_port           = 123
  protocol          = "udp"
  description       = "NTP-UDP"
  cidr_blocks       = local.ingress_cidr_blocks_list
  security_group_id = aws_security_group.ec2_sg["ec2_sg"].id
}

resource "aws_security_group_rule" "smb_netbios_tcp" {
  for_each          = var.create_security_group == true ? toset(["smb_netbios_tcp"]) : toset([])
  type              = "ingress"
  from_port         = 139
  to_port           = 139
  protocol          = "tcp"
  description       = "SMB over NetBIOS - TCP"
  cidr_blocks       = local.ingress_cidr_blocks_list
  security_group_id = aws_security_group.ec2_sg["ec2_sg"].id
}

resource "aws_security_group_rule" "smb_netbios_udp" {
  for_each          = var.create_security_group == true ? toset(["smb_netbios_udp"]) : toset([])
  type              = "ingress"
  from_port         = 139
  to_port           = 139
  protocol          = "udp"
  description       = "SMB over NetBIOS - UDP"
  cidr_blocks       = local.ingress_cidr_blocks_list
  security_group_id = aws_security_group.ec2_sg["ec2_sg"].id
}

resource "aws_security_group_rule" "smb_tcp" {
  for_each          = var.create_security_group == true ? toset(["smb_tcp"]) : toset([])
  type              = "ingress"
  from_port         = 445
  to_port           = 455
  protocol          = "tcp"
  description       = "SMB"
  cidr_blocks       = local.ingress_cidr_blocks_list
  security_group_id = aws_security_group.ec2_sg["ec2_sg"].id
}

#outbound connections for Storage Gateway for activation
#tfsec:ignore:aws-vpc-no-public-egress-sgr
resource "aws_security_group_rule" "egress" {
  for_each          = var.create_security_group == true ? toset(["egress"]) : toset([])
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  description       = "Storage Gateway egress traffic for activation"
  cidr_blocks       = local.egress_cidr_blocks_list
  security_group_id = aws_security_group.ec2_sg["ec2_sg"].id
}


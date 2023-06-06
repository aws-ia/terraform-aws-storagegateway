resource "aws_security_group" "ec2_sg" {
  
  #count       = var.create_security_group ? 1 : 0
  for_each = var.create_security_group == true ? toset(["ec2_sg"]) : toset([])
  
  name        = "${var.name}.security-group"
  description = "Security group with custom ports open within VPC for client connectivity and communication with AWS."
  vpc_id      = var.vpc_id

  ingress {

    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "HTTP required only for activation purposes. The port is closed after activation."
    cidr_blocks = var.ingress_cidr_block_activation
  }
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    description = "NFS-TCP"
    cidr_blocks = var.ingress_cidr_blocks
  }
  ingress {
    from_port   = 111
    to_port     = 111
    protocol    = "tcp"
    description = "NFS"
    cidr_blocks = var.ingress_cidr_blocks
  }
  ingress {
    from_port   = 20048
    to_port     = 20048
    protocol    = "tcp"
    description = "NFSv3-TCP"
    cidr_blocks = var.ingress_cidr_blocks
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "HTTPS"
    cidr_blocks = var.ingress_cidr_blocks
  }
  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    description = "DNS-TCP"
    cidr_blocks = var.ingress_cidr_blocks
  }
  ingress {
    from_port   = 123
    to_port     = 123
    protocol    = "udp"
    description = "NTP"
    cidr_blocks = var.ingress_cidr_blocks
  }
  ingress {
    from_port   = 445
    to_port     = 445
    protocol    = "tcp"
    description = "SMB"
    cidr_blocks = var.ingress_cidr_blocks
  }
  # ingress {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   description = "All Traffic"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

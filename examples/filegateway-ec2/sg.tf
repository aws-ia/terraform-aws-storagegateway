module "ec2_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.project}.security-group"
  description = "Security group for user-service with custom ports open within VPC, and PostgreSQL publicly open"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks      = [var.vpc-ipv4-cidr]
  ingress_rules            = ["ssh-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 2049
      to_port     = 2049
      protocol    = "tcp"
      description = "NFS-TCP"
      cidr_blocks = var.vpc-ipv4-cidr
    },
    {
      from_port   = 111
      to_port     = 111
      protocol    = "tcp"
      description = "NFS"
      cidr_blocks = var.vpc-ipv4-cidr
    },
    {
      from_port   = 20048
      to_port     = 20048
      protocol    = "tcp"
      description = "NFSv3-TCP"
      cidr_blocks = var.vpc-ipv4-cidr
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS"
      cidr_blocks = var.vpc-ipv4-cidr
    },
    {
      from_port   = 53
      to_port     = 53
      protocol    = "tcp"
      description = "DNS-TCP"
      cidr_blocks = var.vpc-ipv4-cidr
    },
    {
      from_port   = 123
      to_port     = 123
      protocol    = "udp"
      description = "NTP"
      cidr_blocks = var.vpc-ipv4-cidr
    }
  ]
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules = ["all-all"]
}

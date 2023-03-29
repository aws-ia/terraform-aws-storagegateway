data "aws_availability_zones" "available" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  cidr = var.vpc-ipv4-cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, (var.subnet-count))
  private_subnets = [for subnet in range(var.subnet-count) : cidrsubnet(var.vpc-ipv4-cidr, 8, subnet)]
  public_subnets  = [for subnet in range(var.subnet-count) : cidrsubnet(var.vpc-ipv4-cidr, 8, sum([subnet, var.subnet-count]))]

  enable_dns_hostnames    = true

}

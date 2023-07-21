######################################
# Defaults and Locals
######################################

resource "random_pet" "name" {
  prefix = "aws-ia"
  length = 1
}

locals {
  share_name      = "${random_pet.name.id}-${module.sgw.storage_gateway.gateway_id}"
  client_ip_cidrs = split(",", var.client_ip_cidrs) #converting string to list type
}

######################################
# Create S3 File Gateway
######################################

module "sgw" {
  depends_on                         = [module.ec2_sgw]
  source                             = "../../modules/aws-sgw"
  gateway_name                       = random_pet.name.id
  gateway_ip_address                 = module.ec2_sgw.public_ip
  join_smb_domain                    = false
  gateway_type                       = "FILE_S3"
  create_vpc_endpoint                = true
  create_vpc_endpoint_security_group = true #if false define vpc_endpoint_security_group_id 
  vpc_id                             = module.vpc.vpc_id
  vpc_endpoint_subnet_ids            = module.vpc.private_subnets
  gateway_private_ip_address         = module.ec2_sgw.private_ip
}

#######################################
# Create EC2  File Gateway
#######################################

module "ec2_sgw" {

  source            = "../../modules/ec2-sgw"
  vpc_id            = module.vpc.vpc_id
  subnet_id         = module.vpc.public_subnets[0]
  name              = "${random_pet.name.id}-gateway"
  availability_zone = data.aws_availability_zones.available.names[0]
  ssh_key_name      = local.ssh_key_name

  #If create security_group = true , define ingress cidr blocks, if not use security_group_id
  create_security_group         = true
  ingress_cidr_blocks           = var.ingress_cidr_blocks
  ingress_cidr_block_activation = var.ingress_cidr_block_activation

  # Cache and Root Volume encryption key
  cache_block_device = {
    kms_key_id = aws_kms_key.sgw.arn
  }

  root_block_device = {
    kms_key_id = aws_kms_key.sgw.arn
  }

}

#############################
# Create VPC and Subnets 
#############################

data "aws_availability_zones" "available" {}

#VPC flow logs enabled. Skipping tfsec bug https://github.com/aquasecurity/tfsec/issues/1941
#tfsec:ignore:aws-ec2-require-vpc-flow-logs-for-all-vpcs
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">=5.0.0"

  cidr = var.vpc_cidr_block

  azs             = slice(data.aws_availability_zones.available.names, 0, (var.subnet-count))
  private_subnets = [for subnet in range(var.subnet-count) : cidrsubnet(var.vpc_cidr_block, 8, subnet)] # For Private subnets
  public_subnets  = [for subnet in range(var.subnet-count) : cidrsubnet(var.vpc_cidr_block, 8, sum([subnet, var.subnet-count]))]
  name            = "${random_pet.name.id}-gateway-vpc"

  enable_dns_hostnames                 = true
  create_igw                           = true
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60
}

###################################
# Create S3 Gateway VPC Endpoint
###################################

resource "aws_vpc_endpoint" "s3" {
  vpc_id          = module.vpc.vpc_id
  service_name    = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids = module.vpc.private_route_table_ids
}

#######################################
# Create S3 bucket for File Gateway 
#######################################

#Versioning disabled as per guidnance from the create SMB file share documentation. Read https://docs.aws.amazon.com/filegateway/latest/files3/CreatingAnSMBFileShare.html
#tfsec:ignore:aws-s3-enable-versioning
module "s3_bucket" {
  source                   = "terraform-aws-modules/s3-bucket/aws"
  version                  = ">=3.5.0"
  bucket                   = lower("${random_pet.name.id}-${module.sgw.storage_gateway.gateway_id}-s3-fgw")
  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"
  block_public_acls        = true
  block_public_policy      = true
  ignore_public_acls       = true
  restrict_public_buckets  = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = aws_kms_key.sgw.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  logging = {
    target_bucket = module.log_delivery_bucket.s3_bucket_id
    target_prefix = "log/"
  }

  versioning = {
    enabled = false
  }
}

#######################################
# Create NFS File share
#######################################

module "nfs_share" {
  source        = "../../modules/s3-nfs-share"
  share_name    = "${local.share_name}-fs"
  gateway_arn   = module.sgw.storage_gateway.arn
  bucket_arn    = module.s3_bucket.s3_bucket_arn
  role_arn      = aws_iam_role.sgw.arn
  log_group_arn = aws_cloudwatch_log_group.smbshare.arn
  client_list   = local.client_ip_cidrs
  kms_encrypted = true
  kms_key_arn   = aws_kms_key.sgw.arn
}

#######################################################################
# Create S3 bucket for Server Access Logs (Optional if already exists)
#######################################################################

#TFSEC Bucket logging for services access logs supressed. 
#tfsec:ignore:aws-s3-enable-bucket-logging
module "log_delivery_bucket" {
  source                   = "terraform-aws-modules/s3-bucket/aws"
  version                  = ">=3.5.0"
  bucket                   = lower("${random_pet.name.id}-${module.sgw.storage_gateway.gateway_id}-s3-fgw-logs")
  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"
  block_public_acls        = true
  block_public_policy      = true
  ignore_public_acls       = true
  restrict_public_buckets  = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = aws_kms_key.sgw.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  versioning = {
    enabled = true
  }
}

resource "aws_kms_key" "sgw" {
  description             = "KMS key for encrypting S3 buckets and EBS volumes"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

locals {
  ssh_key_name = length(var.ssh_public_key_path) > 0 ? aws_key_pair.ec2_sgw_key_pair["ec2_sgw_key_pair"].key_name : null
}

resource "aws_key_pair" "ec2_sgw_key_pair" {

  for_each = length(var.ssh_public_key_path) > 0 ? toset(["ec2_sgw_key_pair"]) : toset([])

  key_name   = var.ssh_key_name
  public_key = file(var.ssh_public_key_path)
}




#####################################################################
# Create log group for SMB File share (Optional if already created)
#####################################################################

#TFSEC Low warning for cloudwatch-log-group customer key supressed. 
#tfsec:ignore:aws-cloudwatch-log-group-customer-key
resource "aws_cloudwatch_log_group" "smbshare" {
  name = "${local.share_name}-auditlogs"

  tags = {
    Environment = "dev"
    Application = "serviceA"
  }
}

#############################################################################
# Create IAM role and policy for SGW to use S3 (Optional if already created)
##############################################################################

resource "aws_iam_role" "sgw" {
  name               = "${local.share_name}-role"
  assume_role_policy = data.aws_iam_policy_document.sgw.json
}

resource "aws_iam_policy" "sgw" {
  policy = data.aws_iam_policy_document.bucket_sgw.json
}

resource "aws_iam_role_policy_attachment" "sgw" {
  role       = aws_iam_role.sgw.name
  policy_arn = aws_iam_policy.sgw.arn
}

data "aws_iam_policy_document" "sgw" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["storagegateway.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "bucket_sgw" {
  statement {
    sid       = "AllowStorageGatewayBucketTopLevelAccess"
    effect    = "Allow"
    resources = [module.s3_bucket.s3_bucket_arn]
    actions = [
      "s3:GetAccelerateConfiguration",
      "s3:GetBucketLocation",
      "s3:GetBucketVersioning",
      "s3:ListBucket",
      "s3:ListBucketVersions",
      "s3:ListBucketMultipartUploads"
    ]
  }
  #TFSEC Warning for /* in the S3 bucket prefix supressed as the objects are unknown before creation.
  #tfsec:ignore:aws-iam-no-policy-wildcards 
  statement {
    sid       = "AllowStorageGatewayBucketObjectLevelAccess"
    effect    = "Allow"
    resources = ["${module.s3_bucket.s3_bucket_arn}/*"]
    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectVersion",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
  }
}
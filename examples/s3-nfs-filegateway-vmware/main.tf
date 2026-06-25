######################################
# Defaults and Locals
######################################

resource "random_pet" "name" {
  prefix = "aws-ia"
  length = 1
}

locals {
  share_name = "${random_pet.name.id}-${module.sgw.storage_gateway.gateway_id}"
}

######################################
# Create S3 File Gateway
######################################

module "sgw" {
  depends_on         = [module.vsphere]
  source             = "../../modules/aws-sgw"
  gateway_name       = random_pet.name.id
  gateway_ip_address = module.vsphere.vm_ip
  join_smb_domain    = false
  gateway_type       = "FILE_S3"
  disk_node          = "SCSI (0:1)"
}

#######################################
# Create OVF ESXi  File Gateway
#######################################

module "vsphere" {
  source            = "../../modules/vmware-sgw"
  datastore         = var.datastore
  datacenter        = var.datacenter
  network           = var.network
  cluster           = var.cluster
  host              = var.host
  name              = "${random_pet.name.id}-gateway"
  deployment_option = "new-gateway"
}

#######################################
# Create S3 bucket for File Gateway 
#######################################

#Versioning disabled as per guidance from the create SMB file share documentation. Read https://docs.aws.amazon.com/filegateway/latest/files3/CreatingAnSMBFileShare.html
#tfsec:ignore:aws-s3-enable-versioning
module "s3_bucket" {
  source                   = "terraform-aws-modules/s3-bucket/aws"
  version                  = "~> 5.0"
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
  client_list   = var.client_list
}

#######################################################################
# Create S3 bucket for Server Access Logs (Optional if already exists)
#######################################################################

#TFSEC Bucket logging for services access logs suppressed. 
#tfsec:ignore:aws-s3-enable-bucket-logging
module "log_delivery_bucket" {
  source                   = "terraform-aws-modules/s3-bucket/aws"
  version                  = "~> 5.0"
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

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_kms_key" "sgw" {
  description             = "KMS key for encrypting S3 buckets and CloudWatch Logs"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms_key_policy.json
}

data "aws_iam_policy_document" "kms_key_policy" {
  #checkov:skip=CKV_AWS_111:KMS key policy requires * resource to refer to the key itself
  #checkov:skip=CKV_AWS_109:KMS key policy requires * resource to refer to the key itself
  #checkov:skip=CKV_AWS_356:KMS key policy requires * resource to refer to the key itself
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow CloudWatch Logs"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.id}.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = ["*"]
    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:aws:logs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:*"]
    }
  }
}

#####################################################################
# Create log group for SMB File share (Optional if already created)
#####################################################################

resource "aws_cloudwatch_log_group" "smbshare" {
  name              = "${local.share_name}-auditlogs"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.sgw.arn

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
  #TFSEC Warning for /* in the S3 bucket prefix suppressed as the objects are unknown before creation.
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
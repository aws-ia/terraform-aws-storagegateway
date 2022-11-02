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
# Create S3  File Gateway
######################################
module "sgw" {
  depends_on         = [module.vsphere]
  source             = "../../modules/aws-sgw"
  name               = random_pet.name.id
  gateway_ip_address = module.vsphere.vm_ip
  domain_name        = "labster.local"
  domain_username    = "svc_sgw_terraform"
  domain_password    = var.domain_password
  domain_controllers = var.domain_controllers
  gateway_type       = "FILE_S3"
}

#######################################
# Create OVF ESXi  File Gateway
#######################################
module "vsphere" {
  source     = "../../modules/vmware-sgw"
  datastore  = "Helhest"
  datacenter = "Datacenter"
  network    = "VM Network"
  cluster    = "ESX 7.0 Cluster"
  host       = "10.0.0.248"
  name       = "${random_pet.name.id}-gateway"
}

#######################################
# Create S3 bucket for File Gateway 
#######################################
module "s3_bucket" {
  source                  = "terraform-aws-modules/s3-bucket/aws"
  version                 = ">=3.5.0"
  bucket                  = lower("${random_pet.name.id}-${module.sgw.storage_gateway.gateway_id}-s3-fgw")
  acl                     = "private"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true


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
    enabled = true
  }
}

#######################################
# Create SMB File share
#######################################
module "smb_share" {
  source        = "../../modules/s3-smb-share"
  share_name    = "${local.share_name}-fs"
  gateway_arn   = module.sgw.storage_gateway.arn
  bucket_arn    = module.s3_bucket.s3_bucket_arn
  role_arn      = aws_iam_role.sgw.arn
  log_group_arn = aws_cloudwatch_log_group.smbshare.arn
}

#######################################################################
# Create S3 bucket for Server Access Logs (Optional if already exists)
#######################################################################


#TFSEC Bucket logging for services access logs supressed. 
#tfsec:ignore:aws-s3-enable-bucket-logging
module "log_delivery_bucket" {
  source                  = "terraform-aws-modules/s3-bucket/aws"
  version                 = ">=3.5.0"
  bucket                  = lower("${random_pet.name.id}-${module.sgw.storage_gateway.gateway_id}-s3-fgw-logs")
  acl                     = "private"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true


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
  description             = "KMS key for S3 object"
  deletion_window_in_days = 7
  enable_key_rotation     = true
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
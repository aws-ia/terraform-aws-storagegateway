##################################
# Create Public S3 file gateway
##################################

resource "aws_storagegateway_gateway" "EC2FileGateway" {
  depends_on         = [aws_ebs_volume.cache-disk , module.SGW_Instance]
  gateway_ip_address = aws_eip.ip.public_ip
  gateway_name       = var.gateway_name
  gateway_timezone   = "GMT"
  gateway_type       = "FILE_S3"
  
}

#########################
# Configure Cache disk
#########################

data "aws_storagegateway_local_disk" "GatewayLocalDisk" {
  disk_node   = aws_volume_attachment.ebs_volume.device_name  //"/dev/xvdb" //
  gateway_arn = aws_storagegateway_gateway.EC2FileGateway.arn
}

resource "aws_storagegateway_cache" "s3FileGWCache" {
  disk_id     = data.aws_storagegateway_local_disk.GatewayLocalDisk.disk_id
  gateway_arn = aws_storagegateway_gateway.EC2FileGateway.arn
}

######################
# Create S3 Bucket
######################

module "s3_bucket" {
  source                   = "terraform-aws-modules/s3-bucket/aws"
  version                  = ">=3.5.0"
  bucket                   = lower("${var.project}-s3-fgw")
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
    enabled = false
  }
}

resource "aws_kms_key" "sgw" {
  description             = "KMS key for S3 object"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}


#####################
# Create NFS Share
#####################

resource "aws_storagegateway_nfs_file_share" "nfsShare" {
  depends_on   = [aws_storagegateway_gateway.EC2FileGateway, aws_iam_role.sgw]
  client_list  = [var.vpc-ipv4-cidr]
  gateway_arn  = aws_storagegateway_gateway.EC2FileGateway.arn
  location_arn = module.s3_bucket.s3_bucket_arn
  role_arn     = aws_iam_role.sgw.arn
}

###########################
# SGW IAM access S3 role
###########################

resource "aws_iam_role" "sgw" {
  name               = "${var.project}-storagegateway-role"
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

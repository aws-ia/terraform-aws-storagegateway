## Storage gateway EC2 instance ID :
output "EC2 InstanceID" {
  description = "Storage gateway instance ID"
  value       = module.SGW_Instance.id
}

## S3 Bucket used for the File Share :
output "s3_bucket_arn" {
  description = "S3 bucket name"
  value       = module.s3_bucket.s3_bucket_arn
}

## Storage gateway ID :
output "GatewayID" {
  description = "S3 file gateway ID"
  value       = aws_storagegateway_gateway.EC2FileGateway.gateway_id
}

## NFS Share ID :
output "NFSShareID" {
  description = "S3 file gateway ID"
  value       = aws_storagegateway_nfs_file_share.nfsShare.fileshare_id
}

## File Share S3 IAM Role :
output "FileShare IAM Role" {
  description = "S3 file gateway ID"
  value       = aws_iam_role.sgw.name
}

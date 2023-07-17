<!-- BEGIN_TF_DOCS -->
# AWS S3 SMB File share Terraform sub-module

Creates an SMB file share backed by S3. For an end to end example on VMware, refer to the [s3filegateway-vmware](../../examples/s3filegateway-vmware/) example.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 0.24.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_storagegateway_nfs_file_share.nfsshare](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/storagegateway_nfs_file_share) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_arn"></a> [bucket\_arn](#input\_bucket\_arn) | Storage Gateway ARN | `string` | n/a | yes |
| <a name="input_client_list"></a> [client\_list](#input\_client\_list) | The list of clients that are allowed to access the file gateway. The list must contain either valid IP addresses or valid CIDR blocks. Minimum 1 item. Maximum 100 items. | `list(any)` | n/a | yes |
| <a name="input_gateway_arn"></a> [gateway\_arn](#input\_gateway\_arn) | Storage Gateway ARN | `string` | n/a | yes |
| <a name="input_log_group_arn"></a> [log\_group\_arn](#input\_log\_group\_arn) | Cloudwatch Log Group ARN for audit logs | `string` | n/a | yes |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | The ARN of the AWS Identity and Access Management (IAM) role that a file gateway assumes when it accesses the underlying storage. | `string` | n/a | yes |
| <a name="input_share_name"></a> [share\_name](#input\_share\_name) | Name of the nfs file share | `string` | n/a | yes |
| <a name="input_cache_timout"></a> [cache\_timout](#input\_cache\_timout) | Cache stale timeout for automated cache refresh in seconds. Default is set to 1 hour (3600 seconds) can be changed to as low as 5 minutes (300 seconds) | `number` | `"3600"` | no |
| <a name="input_directory_mode"></a> [directory\_mode](#input\_directory\_mode) | (Optional) The Unix directory mode in the string form "nnnn". Defaults to "0777" value | `string` | `"0777"` | no |
| <a name="input_file_mode"></a> [file\_mode](#input\_file\_mode) | (Optional) The Unix file mode in the string form "nnnn". Defaults to "0666" | `string` | `"0666"` | no |
| <a name="input_group_id"></a> [group\_id](#input\_group\_id) | (Optional) The default group ID for the file share (unless the files have another group ID specified). Defaults to 65534 (nfsnobody). Valid values: 0 through 4294967294 | `number` | `"65534"` | no |
| <a name="input_kms_encrypted"></a> [kms\_encrypted](#input\_kms\_encrypted) | (Optional) Boolean value if true to use Amazon S3 server side encryption with your own AWS KMS key, or false to use a key managed by Amazon S3. Defaults to false | `bool` | `false` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | (Optional) Amazon Resource Name (ARN) for KMS key used for Amazon S3 server side encryption. This value can only be set when kms\_encrypted is true. | `string` | `null` | no |
| <a name="input_owner_id"></a> [owner\_id](#input\_owner\_id) | (Optional) The default owner ID for the file share (unless the files have another owner ID specified). Defaults to 65534 (nfsnobody). Valid values: 0 through 4294967294 | `number` | `"65534"` | no |
| <a name="input_storage_class"></a> [storage\_class](#input\_storage\_class) | Storage class for NFS file share. Valid options are S3\_STANDARD \| S3\_INTELLIGENT\_TIERING \| S3\_STANDARD\_IA \| S3\_ONEZONE\_IA | `string` | `"S3_STANDARD"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nfs_share_arn"></a> [nfs\_share\_arn](#output\_nfs\_share\_arn) | The ARN of the created NFS File Share. |
| <a name="output_nfs_share_path"></a> [nfs\_share\_path](#output\_nfs\_share\_path) | The path of the created NFS File Share. |
<!-- END_TF_DOCS -->
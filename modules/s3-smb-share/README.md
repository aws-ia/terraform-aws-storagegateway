<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0, < 5.0.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 0.24.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.37.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_storagegateway_smb_file_share.smbshare](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/storagegateway_smb_file_share) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_user_list"></a> [admin\_user\_list](#input\_admin\_user\_list) | A list of users in the Active Directory that have admin access to the file share. | `list(any)` | <pre>[<br>  "Domain Admins"<br>]</pre> | no |
| <a name="input_bucket_arn"></a> [bucket\_arn](#input\_bucket\_arn) | Storage Gateway ARN | `string` | n/a | yes |
| <a name="input_gateway_arn"></a> [gateway\_arn](#input\_gateway\_arn) | Storage Gateway ARN | `string` | n/a | yes |
| <a name="input_log_group_arn"></a> [log\_group\_arn](#input\_log\_group\_arn) | Cloudwatch Log Group ARN for audit logs | `string` | n/a | yes |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | The ARN of the AWS Identity and Access Management (IAM) role that a file gateway assumes when it accesses the underlying storage. | `string` | n/a | yes |
| <a name="input_share_name"></a> [share\_name](#input\_share\_name) | Name of the smb file share | `string` | n/a | yes |
| <a name="input_storage_class"></a> [storage\_class](#input\_storage\_class) | Storage Gateway ARN | `string` | `"S3_STANDARD"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_smb_share_arn"></a> [smb\_share\_arn](#output\_smb\_share\_arn) | The ARN of the created SMB File Share. |
| <a name="output_smb_share_path"></a> [smb\_share\_path](#output\_smb\_share\_path) | The path of the created SMB File Share. |
<!-- END_TF_DOCS -->
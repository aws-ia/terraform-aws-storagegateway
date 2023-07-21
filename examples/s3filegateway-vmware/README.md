<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0, < 5.0.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 0.24.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >=3.4.0 |
| <a name="requirement_vsphere"></a> [vsphere](#requirement\_vsphere) | >=2.2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0.0, < 5.0.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >=3.4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_log_delivery_bucket"></a> [log\_delivery\_bucket](#module\_log\_delivery\_bucket) | terraform-aws-modules/s3-bucket/aws | >=3.5.0 |
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | terraform-aws-modules/s3-bucket/aws | >=3.5.0 |
| <a name="module_sgw"></a> [sgw](#module\_sgw) | ../../modules/aws-sgw | n/a |
| <a name="module_smb_share"></a> [smb\_share](#module\_smb\_share) | ../../modules/s3-smb-share | n/a |
| <a name="module_vsphere"></a> [vsphere](#module\_vsphere) | ../../modules/vmware-sgw | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.smbshare](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.sgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.sgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.sgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_key.sgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [random_pet.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [aws_iam_policy_document.bucket_sgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_unverified_ssl"></a> [allow\_unverified\_ssl](#input\_allow\_unverified\_ssl) | Boolean that can be set to true to disable SSL certificate verification. | `bool` | `false` | no |
| <a name="input_cluster"></a> [cluster](#input\_cluster) | Cluster where the aws storage gateway will be deployed | `string` | n/a | yes |
| <a name="input_datacenter"></a> [datacenter](#input\_datacenter) | Name of the vsphere datacenter where the aws storage gateway will be deployed | `string` | n/a | yes |
| <a name="input_datastore"></a> [datastore](#input\_datastore) | Name of the vsphere datastore where the aws storage gateway will be deployed | `string` | n/a | yes |
| <a name="input_domain_controllers"></a> [domain\_controllers](#input\_domain\_controllers) | Comma separated list of domain controllers. | `list(any)` | `[]` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Domain name | `string` | n/a | yes |
| <a name="input_domain_password"></a> [domain\_password](#input\_domain\_password) | The password for the service account on your self-managed AD domain that SGW will use to join to your AD domain | `string` | n/a | yes |
| <a name="input_domain_username"></a> [domain\_username](#input\_domain\_username) | The user name for the service account on your self-managed AD domain that SGW use to join to your AD domain | `string` | n/a | yes |
| <a name="input_host"></a> [host](#input\_host) | Target host used during deployment of the ova | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | Name of the vsphere port group that the aws storage gateway will use | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The name of the region you wish to deploy into | `string` | `"us-east-1"` | no |
| <a name="input_vsphere_password"></a> [vsphere\_password](#input\_vsphere\_password) | The password for the vcenter server | `string` | n/a | yes |
| <a name="input_vsphere_server"></a> [vsphere\_server](#input\_vsphere\_server) | vSphere server IP address or fqdn | `string` | n/a | yes |
| <a name="input_vsphere_user"></a> [vsphere\_user](#input\_vsphere\_user) | vSphere service account user name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | The ARN of the bucket. Will be of format arn:aws:s3:::bucketname. |
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | The name of the bucket. |
| <a name="output_smb_share_arn"></a> [smb\_share\_arn](#output\_smb\_share\_arn) | ARN of the created SMB share |
| <a name="output_smb_share_path"></a> [smb\_share\_path](#output\_smb\_share\_path) | SMB share mountpoint path |
| <a name="output_storage_gateway_id"></a> [storage\_gateway\_id](#output\_storage\_gateway\_id) | Storage Gateway ID |
<!-- END_TF_DOCS -->
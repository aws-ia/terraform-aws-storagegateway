<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 0.24.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >=3.4.0 |
| <a name="requirement_vsphere"></a> [vsphere](#requirement\_vsphere) | >=2.2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.8.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.5.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ec2_sgw"></a> [ec2\_sgw](#module\_ec2\_sgw) | ../../modules/ec2-sgw | n/a |
| <a name="module_log_delivery_bucket"></a> [log\_delivery\_bucket](#module\_log\_delivery\_bucket) | terraform-aws-modules/s3-bucket/aws | >=3.5.0 |
| <a name="module_nfs_share"></a> [nfs\_share](#module\_nfs\_share) | ../../modules/s3-nfs-share | n/a |
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | terraform-aws-modules/s3-bucket/aws | >=3.5.0 |
| <a name="module_sgw"></a> [sgw](#module\_sgw) | ../../modules/aws-sgw | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | >=5.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.smbshare](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.sgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.sgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.sgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_key_pair.ec2_sgw_key_pair](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_kms_key.sgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_vpc_endpoint.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [random_pet.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_iam_policy_document.bucket_sgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Region for AWS Resources | `string` | n/a | yes |
| <a name="input_client_ip_cidrs"></a> [client\_ip\_cidrs](#input\_client\_ip\_cidrs) | The IP addresses or CIDR block of clients that are allowed to access the file gateway. If there are multiple clients, please separate using commas. The value must contain valid CIDR blocks. Minimum 1 item. Maximum 100 items. | `string` | n/a | yes |
| <a name="input_ingress_cidr_block_activation"></a> [ingress\_cidr\_block\_activation](#input\_ingress\_cidr\_block\_activation) | The CIDR block to allow ingress port 80 into your File Gateway instance for activation. For multiple CIDR blocks, please separate with comma | `string` | n/a | yes |
| <a name="input_ingress_cidr_blocks"></a> [ingress\_cidr\_blocks](#input\_ingress\_cidr\_blocks) | The CIDR blocks to allow ingress into your File Gateway instance for NFS and SMB client access. For multiple CIDR blocks, please separate with comma | `string` | `"10.0.0.0/16"` | no |
| <a name="input_ssh_key_name"></a> [ssh\_key\_name](#input\_ssh\_key\_name) | (Optional) The name of an existing EC2 Key pair for SSH access to the EC2 Storage Gateway appliance | `string` | `null` | no |
| <a name="input_ssh_public_key_path"></a> [ssh\_public\_key\_path](#input\_ssh\_public\_key\_path) | (Optional) Absolute file path to the the public key for the EC2 Key pair. If ommitted, the EC2 key pair resource will not be created | `string` | `""` | no |
| <a name="input_subnet-count"></a> [subnet-count](#input\_subnet-count) | Number of sunbets per type | `number` | `1` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | VPC CIDR block for the creation of example VPC and subnets | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nfs_share_arn"></a> [nfs\_share\_arn](#output\_nfs\_share\_arn) | ARN of the created NFS share |
| <a name="output_nfs_share_path"></a> [nfs\_share\_path](#output\_nfs\_share\_path) | NFS share mountpoint path |
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | The ARN of the bucket. Will be of format arn:aws:s3:::bucketname. |
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | The name of the bucket. |
| <a name="output_storage_gateway_id"></a> [storage\_gateway\_id](#output\_storage\_gateway\_id) | Storage Gateway ID |
<!-- END_TF_DOCS -->
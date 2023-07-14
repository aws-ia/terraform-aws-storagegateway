<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ebs_volume.cache-disk](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |
| [aws_eip.ip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip_association.eip_assoc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_instance.ec2-sgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_key_pair.ec2_sgw_key_pair](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_security_group.ec2_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_volume_attachment.ebs_volume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [aws_ami.sgw-ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | Availability zone for the Gateway EC2 Instance | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Region for AWS Resources | `string` | n/a | yes |
| <a name="input_cache_block_device"></a> [cache\_block\_device](#input\_cache\_block\_device) | Customize details about the additional block device of the instance. See Block Devices below for details | `map(any)` | <pre>{<br>  "disk_size": 150,<br>  "kms_key_id": null,<br>  "volume_type": "gp3"<br>}</pre> | no |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | Create a Security Group for the EC2 Storage Gateway appliance. If create\_security\_group=false, provide a valid security\_group\_id | `bool` | `false` | no |
| <a name="input_ingress_cidr_block_activation"></a> [ingress\_cidr\_block\_activation](#input\_ingress\_cidr\_block\_activation) | The CIDR block to allow ingress port 80 into your File Gateway instance for activation. For multiple CIDR blocks, please separate with comma | `string` | n/a | yes |
| <a name="input_ingress_cidr_blocks"></a> [ingress\_cidr\_blocks](#input\_ingress\_cidr\_blocks) | The CIDR blocks to allow ingress into your File Gateway instance for NFS and SMB client access. For multiple CIDR blocks, please separate with comma | `string` | `"10.0.0.0/16"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The instance type to use for the Storage Gateway. Insatnce types supported are m5.xlarge is the minimum required for a small deployment. For a medium or a large deployment use m5.2xlarge or m5.4xlarge | `string` | `"m5.xlarge"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the EC2 Storage Gateway instance | `string` | `"aws-storage-gateway"` | no |
| <a name="input_root_block_device"></a> [root\_block\_device](#input\_root\_block\_device) | Customize details about the root block device of the instance. See Block Devices below for details | `map(any)` | <pre>{<br>  "disk_size": 80,<br>  "kms_key_id": null,<br>  "volume_type": "gp3"<br>}</pre> | no |
| <a name="input_security_group_id"></a> [security\_group\_id](#input\_security\_group\_id) | Optionally provide an existing Security Group ID to associate with EC2 Storage Gateway appliance. Variable create\_security\_group should be set to false to use an existing Security Group | `string` | `null` | no |
| <a name="input_ssh_key_name"></a> [ssh\_key\_name](#input\_ssh\_key\_name) | The name of EC2 Key pair for SSH access to the EC2 Storage Gateway appliance | `string` | `"ec2-sgw-key-pair"` | no |
| <a name="input_ssh_public_key_path"></a> [ssh\_public\_key\_path](#input\_ssh\_public\_key\_path) | Absolute file path to the the public key for the EC2 Key pair | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | VPC Subnet ID to launch in the EC2 Instance | `string` | n/a | yes |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | Time zone for the gateway. The time zone is of the format GMT, GMT-hr:mm, or GMT+hr:mm.For example, GMT-4:00 indicates the time is 4 hours behind GMT. Avoid prefixing with 0 | `string` | `"GMT"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC ID in which the Storage Gateway security group will be created in | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | The Private IP address of the Storage Gateway EC2 appliance |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | The Public IP address of the created Elastic IP. |
<!-- END_TF_DOCS -->
<!-- BEGIN_TF_DOCS -->
# AWS EC2 Storage Gateway Terraform sub-module

Deployes a Storage Gateway appliance on EC2 along with cache disk.

For an end to end example on VMware, refer to the [s3-nfs-filegateway-ec2](../../examples/s3-nfs-filegateway-ec2/) example.

## Block devices

To customize the root block device of the Storage Gateway EC2 instance, use the `root_block_device` block. It supports the following attributes. All options are optional.
- `kms_key_id`: A optional identifier for the KMS encryption key to use for EBS volume encryption at rest.
- `disk_size`: The size of the drive in GiBs (Default: 80).
- `volume_type`: The type of EBS volume. Can be standard, gp2, gp3, io1, io2, sc1 or st1 (Default: gp3).

To customize the root block device of the Storage Gateway EC2 instance, use the `cache_block_device` block. It supports the following attributes. All options are optional.
- `kms_key_id`: An optional identifier for the KMS encryption key to use for EBS volume encryption at rest.
- `disk_size`: The size of the drive in GiBs (Default: 150)
- `volume_type`: The type of EBS volume. Can be standard, gp2, gp3, io1, io2, sc1 or st1 (Default: gp3).

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
| [aws_ebs_volume.cache_disk](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |
| [aws_eip.ip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip_association.eip_assoc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_instance.ec2_sgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.ec2_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.dns_tcp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.nfs_portmap_udp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.nfs_portmapper_tcp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.nfs_tcp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.nfs_udp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.nfs_v3_tcp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.nfs_v3_udp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ntp_udp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.smb_netbios_tcp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.smb_netbios_udp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.smb_tcp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_volume_attachment.ebs_volume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [aws_ami.sgw_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | Availability zone for the Gateway EC2 Instance | `string` | n/a | yes |
| <a name="input_ingress_cidr_block_activation"></a> [ingress\_cidr\_block\_activation](#input\_ingress\_cidr\_block\_activation) | The CIDR block to allow ingress port 80 into your File Gateway instance for activation. For multiple CIDR blocks, please separate with comma | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | VPC Subnet ID to launch in the EC2 Instance | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC ID in which the Storage Gateway security group will be created in | `string` | n/a | yes |
| <a name="input_cache_block_device"></a> [cache\_block\_device](#input\_cache\_block\_device) | Customize details about the additional block device of the instance. See Block Devices for details | `map(any)` | <pre>{<br>  "disk_size": 150,<br>  "kms_key_id": null,<br>  "volume_type": "gp3"<br>}</pre> | no |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | Create a Security Group for the EC2 Storage Gateway appliance. If create\_security\_group=false, provide a valid security\_group\_id | `bool` | `false` | no |
| <a name="input_egress_cidr_blocks"></a> [egress\_cidr\_blocks](#input\_egress\_cidr\_blocks) | The CIDR blocks for Gateway activation. Defaults to 0.0.0.0/0 | `string` | `"0.0.0.0/0"` | no |
| <a name="input_ingress_cidr_blocks"></a> [ingress\_cidr\_blocks](#input\_ingress\_cidr\_blocks) | The CIDR blocks to allow ingress into your File Gateway instance for NFS and SMB client access. For multiple CIDR blocks, please separate with comma | `string` | `"10.0.0.0/16"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The instance type to use for the Storage Gateway. Insatnce types supported are m5.xlarge is the minimum required for a small deployment. For a medium or a large deployment use m5.2xlarge or m5.4xlarge | `string` | `"m5.xlarge"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the EC2 Storage Gateway instance | `string` | `"aws-storage-gateway"` | no |
| <a name="input_root_block_device"></a> [root\_block\_device](#input\_root\_block\_device) | Customize details about the root block device of the instance. See Block Devices for details | `map(any)` | <pre>{<br>  "disk_size": 80,<br>  "kms_key_id": null,<br>  "volume_type": "gp3"<br>}</pre> | no |
| <a name="input_security_group_id"></a> [security\_group\_id](#input\_security\_group\_id) | Optionally provide an existing Security Group ID to associate with EC2 Storage Gateway appliance. Variable create\_security\_group should be set to false to use an existing Security Group | `string` | `null` | no |
| <a name="input_ssh_key_name"></a> [ssh\_key\_name](#input\_ssh\_key\_name) | (Optional) The name of an existing EC2 Key pair for SSH access to the EC2 Storage Gateway appliance | `string` | `null` | no |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | Time zone for the gateway. The time zone is of the format GMT, GMT-hr:mm, or GMT+hr:mm.For example, GMT-4:00 indicates the time is 4 hours behind GMT. Avoid prefixing with 0 | `string` | `"GMT"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | The Private IP address of the Storage Gateway EC2 appliance |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | The Public IP address of the created Elastic IP. |
<!-- END_TF_DOCS -->
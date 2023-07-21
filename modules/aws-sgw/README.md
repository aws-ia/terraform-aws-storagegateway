<!-- BEGIN_TF_DOCS -->
# AWS Storage Gateway Terraform sub-module

Deploys a Storage Gateway on AWS, configures Storage Gateway cache and maps it to a local storage disk. Requires the Storage Gateway appliance to be deployed first using the module [vmware-sgw](../vmware-sgw/) or the [ec2-sgw](../ec2-sgw/). For an end to end examples refer to the [examples directory](../../examples/)

# AWS Storage Gateway types

- Amazon S3 File Gateway (FILE\_S3)
- Amazon FSx File Gateway (FILE\_FSX\_SMB)
- Tape Gateway (VTL)
- Volume Gateway (CACHED, STORED)

The module requires a Gateway Type to be declared with a default set to FILE\_S3. For more details regarding the Storage Gateway types and their respective arguments can be found [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/storagegateway_gateway)

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
| [aws_security_group.vpce_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.vpce_1031](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.vpce_2222](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.vpce_443](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.vpce_dynamic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_storagegateway_cache.sgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/storagegateway_cache) | resource |
| [aws_storagegateway_gateway.mysgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/storagegateway_gateway) | resource |
| [aws_vpc_endpoint.sgw_vpce](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_storagegateway_local_disk.sgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/storagegateway_local_disk) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gateway_ip_address"></a> [gateway\_ip\_address](#input\_gateway\_ip\_address) | IP Address of the SGW appliance in vSphere | `string` | n/a | yes |
| <a name="input_gateway_name"></a> [gateway\_name](#input\_gateway\_name) | Storage Gateway Name | `string` | n/a | yes |
| <a name="input_create_vpc_endpoint"></a> [create\_vpc\_endpoint](#input\_create\_vpc\_endpoint) | Create an interface VPC endpoint for the Storage Gateway | `bool` | `false` | no |
| <a name="input_create_vpc_endpoint_security_group"></a> [create\_vpc\_endpoint\_security\_group](#input\_create\_vpc\_endpoint\_security\_group) | Create a Security Group for the VPC Endpoint for Storage Gateway appliance. | `bool` | `false` | no |
| <a name="input_disk_node"></a> [disk\_node](#input\_disk\_node) | Disk node on the SGW appliance where the cache disk resides on the OS | `string` | `"/dev/sdb"` | no |
| <a name="input_disk_path"></a> [disk\_path](#input\_disk\_path) | Disk path on the SGW appliance where the cache disk resides on the OS | `string` | `"/dev/sdb"` | no |
| <a name="input_domain_controllers"></a> [domain\_controllers](#input\_domain\_controllers) | List of IPv4 addresses, NetBIOS names, or host names of your domain server. If you need to specify the port number include it after the colon (“:”). For example, mydc.mydomain.com:389. | `list(any)` | `[]` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The name of the domain that you want the gateway to join | `string` | `""` | no |
| <a name="input_domain_password"></a> [domain\_password](#input\_domain\_password) | The password for the service account on your self-managed AD domain that SGW will use to join to your AD domain | `string` | `""` | no |
| <a name="input_domain_username"></a> [domain\_username](#input\_domain\_username) | The user name for the service account on your self-managed AD domain that SGW use to join to your AD domain | `string` | `""` | no |
| <a name="input_gateway_private_ip_address"></a> [gateway\_private\_ip\_address](#input\_gateway\_private\_ip\_address) | Inbound IP address of Gateway VM appliance for Security Group associated with VPC Endpoint. Must be set if create\_vpc\_endpoint=true | `string` | `null` | no |
| <a name="input_gateway_type"></a> [gateway\_type](#input\_gateway\_type) | Type of the gateway. Valid options are FILE\_S3, FILE\_FSX\_SMB, VTL, CACHED, STORED | `string` | `"FILE_S3"` | no |
| <a name="input_gateway_vpc_endpoint"></a> [gateway\_vpc\_endpoint](#input\_gateway\_vpc\_endpoint) | Existing VPC endpoint address to be used when activating your gateway. This variable value will be ignored if setting create\_vpc\_endpoint=true. | `string` | `null` | no |
| <a name="input_join_smb_domain"></a> [join\_smb\_domain](#input\_join\_smb\_domain) | Setting for controlling whether to join the Storage gateway to an Active Directory (AD) domain for Server Message Block (SMB) file shares. Variables domain\_controllers, domain\_name, password and username should also be specified to join AD domain. | `bool` | `true` | no |
| <a name="input_organizational_unit"></a> [organizational\_unit](#input\_organizational\_unit) | The organizational unit (OU) is a container in an Active Directory that can hold users, groups, computers, and other OUs and this parameter specifies the OU that the gateway will join within the AD domain. | `string` | `""` | no |
| <a name="input_timeout_in_seconds"></a> [timeout\_in\_seconds](#input\_timeout\_in\_seconds) | Specifies the time in seconds, in which the JoinDomain operation must complete. The default is 20 seconds. | `number` | `-1` | no |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | Time zone for the gateway. The time zone is of the format GMT, GMT-hr:mm, or GMT+hr:mm.For example, GMT-4:00 indicates the time is 4 hours behind GMT. Avoid prefixing with 0 | `string` | `"GMT"` | no |
| <a name="input_vpc_endpoint_private_dns_enabled"></a> [vpc\_endpoint\_private\_dns\_enabled](#input\_vpc\_endpoint\_private\_dns\_enabled) | Enable private DNS for VPC Endpoint | `bool` | `false` | no |
| <a name="input_vpc_endpoint_security_group_id"></a> [vpc\_endpoint\_security\_group\_id](#input\_vpc\_endpoint\_security\_group\_id) | Optionally provide an existing Security Group ID to associate with the VPC Endpoint. Must be set if create\_vpc\_endpoint\_security\_group=false | `string` | `null` | no |
| <a name="input_vpc_endpoint_subnet_ids"></a> [vpc\_endpoint\_subnet\_ids](#input\_vpc\_endpoint\_subnet\_ids) | Provide existing subnet IDs to associate with the VPC Endpoint. Must provide a valid values if create\_vpc\_endpoint=true. | `list(string)` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC id for creating a VPC endpoint. Must provide a valid value if create\_vpc\_endpoint=true. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_storage_gateway"></a> [storage\_gateway](#output\_storage\_gateway) | Storage Gateway Module |
| <a name="output_storage_gateway_name"></a> [storage\_gateway\_name](#output\_storage\_gateway\_name) | Storage Gateway Name |
<!-- END_TF_DOCS -->
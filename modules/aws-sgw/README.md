<!-- BEGIN_TF_DOCS -->
# AWS Storage Gateway Terraform sub-module

Deploys a Storage Gateway on AWS, configures Storage Gateway cache and maps it to a local storage disk. Requires the Storage Gateway appliance to be deployed first using the module [vmware-sgw](../vmware-sgw/). For an end to end example on VMware, refer to the [s3filegateway-vmware](../../examples/s3filegateway-vmware/) example.

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
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0, < 5.0.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 0.24.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0.0, < 5.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_storagegateway_cache.sgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/storagegateway_cache) | resource |
| [aws_storagegateway_gateway.mysgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/storagegateway_gateway) | resource |
| [aws_storagegateway_local_disk.sgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/storagegateway_local_disk) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Domain name | `string` | n/a | yes |
| <a name="input_domain_password"></a> [domain\_password](#input\_domain\_password) | The password for the service account on your self-managed AD domain that SGW will use to join to your AD domain | `string` | n/a | yes |
| <a name="input_domain_username"></a> [domain\_username](#input\_domain\_username) | The user name for the service account on your self-managed AD domain that SGW use to join to your AD domain | `string` | n/a | yes |
| <a name="input_gateway_ip_address"></a> [gateway\_ip\_address](#input\_gateway\_ip\_address) | IP Address of the SGW appliance in vSphere | `string` | n/a | yes |
| <a name="input_gateway_name"></a> [gateway\_name](#input\_gateway\_name) | Storage Gateway Name | `string` | n/a | yes |
| <a name="input_disk_path"></a> [disk\_path](#input\_disk\_path) | Path on the SGW appliance in vsphere where the cache disk resides on the OS | `string` | `"/dev/sdb"` | no |
| <a name="input_domain_controllers"></a> [domain\_controllers](#input\_domain\_controllers) | Comma separated list of domain controllers. | `list(any)` | `[]` | no |
| <a name="input_gateway_type"></a> [gateway\_type](#input\_gateway\_type) | Type of the gateway. Valid options are FILE\_S3, FILE\_FSX\_SMB, VTL, CACHED, STORED | `string` | `"FILE_S3"` | no |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | Time zone for the gateway. The time zone is of the format GMT, GMT-hr:mm, or GMT+hr:mm.For example, GMT-4:00 indicates the time is 4 hours behind GMT. Avoid prefixing with 0 | `string` | `"GMT"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_storage_gateway"></a> [storage\_gateway](#output\_storage\_gateway) | Storage Gateway Name |
<!-- END_TF_DOCS -->
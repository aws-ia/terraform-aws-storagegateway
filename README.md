<!-- BEGIN_TF_DOCS -->
# AWS Storage Gateway Terraform module

This repository contains Terraform code which creates resources required to run Storage Gateway (https://aws.amazon.com/storagegateway/) in AWS and on premises.

AWS Storage Gateway is available in 4 types :

- Amazon S3 File Gateway (FILE\_S3)
- Amazon FSx File Gateway (FILE\_FSX\_SMB)
- Tape Gateway (VTL)
- Volume Gateway (CACHED, STORED)

The module requires a Gateway type to be declared. The default is configured to FILE\_S3 as an example. For more details regarding the Storage Gateway types and their respective arguments can be found [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/storagegateway_gateway).

## Usage with VMware S3 File Gateway module

Link to the example : [s3filegateway-vmware](examples/s3filegateway-vmware)

### Prerequisists

- The VMware module requires the vsphere provider to be setup with a service account user name and password that has the necessary permissions in Vcenter to create a VM. This is found in the [settings.tf](examples/s3filegateway-vmware/settings.tf) file.

```hcl

provider "vsphere" {
  allow_unverified_ssl = var.allow_unverified_ssl
  vsphere_server       = var.vsphere_server
  user                 = var.vsphere_user
  password             = var.vsphere_password
}

```

Note that var.allow\_unverified\_ssl is a boolean that can be set to true to disable SSL certificate verification. This should be used with care as it could allow an attacker to intercept your authentication token. The default value is set to false but can be changed to true for testing purposes only.

The module also requires connectivity to your vCenter server. Therefore it needs to be deployed from a virtual machine that can reach the vCenter APIs. You may also [Terraform Cloud Agents](https://developer.hashicorp.com/terraform/cloud-docs/agents) if you use already use Terrform Cloud. This allows the modules to be deployed remotely.

### [vSphere Module](modules/vmware-sgw/)

```hcl

module "vsphere" {
  source     = "aws-ia/storagegateway/aws//modules/vmware-sgw"
  datastore  = var.datastore
  datacenter = var.datacenter
  network    = var.network
  cluster    = var.cluster
  host       = var.host
  name       = "my-s3fgw"
}
```

The virtual machine IP address needs to be passed to next module as the gateway IP address. In addition, the module also requires domain user name and passwords for the storage gateway to join the domain.

Note that in order to protect sensitive data such as domain credentials etc., certain variables are marked as sensitive. It is general best practice to never store credentials and secrets in git repositories. For more information about protecting sensitive variables refer to [this](https://developer.hashicorp.com/terraform/tutorials/configuration-language/sensitive-variables#reference-sensitive-variables) documentation. Also as a best practice consider the use of services such as [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/), [Hashicorp Vault](https://aws.amazon.com/secrets-manager/) or [Terraform Cloud](https://www.hashicorp.com/blog/managing-credentials-in-terraform-cloud-and-enterprise) to dynamically inject your secrets.

Also note that the domain password despite being a sensitive variable can be still found in the Terraform state file. Follow [this guidance](https://developer.hashicorp.com/terraform/language/state/sensitive-data) to protect state file from unauthorized access.

### [Storage Gateway Module](modules/aws-sgw/)

```hcl
module "sgw" {
  source             = "aws-ia/storagegateway/aws//modules/aws-sgw"
  name               = "my-sgw"
  gateway_ip_address = module.vsphere.vm_ip
  domain_name        = var.domain_name
  domain_username    = var.domain_username
  domain_password    = var.domain_password
  domain_controllers = var.domain_controllers
  gateway_type       = "FILE_S3"       
}

```

## Setting up S3 buckets and SMB File Share

```hcl

module "s3_bucket" {
  source                   = "terraform-aws-modules/s3-bucket/aws"
  version                  = ">=3.5.0"
  bucket                   = "bucket-name"
  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"
  block_public_acls        = true
  block_public_policy      = true
  ignore_public_acls       = true
  restrict_public_buckets  = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = "kms_key_id"
        sse_algorithm     = "aws:kms"
      }
    }
  }
  logging = {
    target_bucket = "log-delivery-bucket"
    target_prefix = "log/"
  }

  versioning = {
    enabled = false
  }
}

#######################################
# Create SMB File share
#######################################
module "smb_share" {
  source        = "aws-ia/storagegateway/aws//modules/s3-smb-share"
  share_name    = "smb_share_name"
  gateway_arn   = module.sgw.storage_gateway.arn
  bucket_arn    = module.s3_bucket.s3_bucket_arn
  role_arn      = "iam-role-for-sgw-s3"
  log_group_arn = "log-group-arn"
}

```

Note that versioning is set to false by default for the S3 bucket for the SMB file share. Enabling S3 Versioning can increase storage costs within Amazon S3. Please see [here](https://docs.aws.amazon.com/filegateway/latest/files3/CreatingAnSMBFileShare.html) for further information on whether S3 Versioning is right for your workload.

The example also includes "aws\_kms\_key" resource block to create a KMS key. For production deployments, you should pass in a key policy that restricts the use of the key based on your access requirements. Refer to this [link](https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html) for information.

## Support & Feedback

Storage Gateway module for Terraform is maintained by AWS Solution Architects. It is not part of an AWS service and support is provided best-effort by the AWS Storage community.

To post feedback, submit feature ideas, or report bugs, please use the [Issues section](https://github.com/aws-ia/terraform-aws-storagegateway/issues) of this GitHub repo.

If you are interested in contributing to the Storage Gateway module, see the [Contribution guide](https://github.com/aws-ia/terraform-aws-storagegateway/blob/main/CONTRIBUTING.md).

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
| <a name="input_gateway_ip_address"></a> [gateway\_ip\_address](#input\_gateway\_ip\_address) | IP Address of the SGW appliance in vSphere | `string` | n/a | yes |
| <a name="input_gateway_name"></a> [gateway\_name](#input\_gateway\_name) | Storage Gateway Name | `string` | n/a | yes |
| <a name="input_organizational_unit"></a> [organizational\_unit](#input\_organizational\_unit) | The organizational unit (OU) is a container in an Active Directory that can hold users, groups, computers, and other OUs and this parameter specifies the OU that the gateway will join within the AD domain. | `string` | n/a | yes |
| <a name="input_timeout_in_seconds"></a> [timeout\_in\_seconds](#input\_timeout\_in\_seconds) | Specifies the time in seconds, in which the JoinDomain operation must complete. The default is 20 seconds. | `number` | n/a | yes |
| <a name="input_disk_path"></a> [disk\_path](#input\_disk\_path) | Path on the SGW appliance in vsphere where the cache disk resides on the OS | `string` | `"/dev/sdb"` | no |
| <a name="input_domain_controllers"></a> [domain\_controllers](#input\_domain\_controllers) | List of IPv4 addresses, NetBIOS names, or host names of your domain server. If you need to specify the port number include it after the colon (“:”). For example, mydc.mydomain.com:389. | `list(any)` | `[]` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The name of the domain that you want the gateway to join | `string` | `""` | no |
| <a name="input_domain_password"></a> [domain\_password](#input\_domain\_password) | The password for the service account on your self-managed AD domain that SGW will use to join to your AD domain | `string` | `""` | no |
| <a name="input_domain_username"></a> [domain\_username](#input\_domain\_username) | The user name for the service account on your self-managed AD domain that SGW use to join to your AD domain | `string` | `""` | no |
| <a name="input_gateway_type"></a> [gateway\_type](#input\_gateway\_type) | Type of the gateway. Valid options are FILE\_S3, FILE\_FSX\_SMB, VTL, CACHED, STORED | `string` | `"FILE_S3"` | no |
| <a name="input_join_smb_domain"></a> [join\_smb\_domain](#input\_join\_smb\_domain) | Setting for controlling whether to join the Storage gateway to an Active Directory (AD) domain for Server Message Block (SMB) file shares. Variables domain\_controllers, domain\_name, password and username should also be specified to join AD domain. | `bool` | `false` | no |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | Time zone for the gateway. The time zone is of the format GMT, GMT-hr:mm, or GMT+hr:mm.For example, GMT-4:00 indicates the time is 4 hours behind GMT. Avoid prefixing with 0 | `string` | `"GMT"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_storage_gateway"></a> [storage\_gateway](#output\_storage\_gateway) | Storage Gateway Name |
<!-- END_TF_DOCS -->
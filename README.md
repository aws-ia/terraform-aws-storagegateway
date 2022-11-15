<!-- BEGIN_TF_DOCS -->
# AWS Storage Gateway Terraform module

This repository contains Terraform infrastructure as code which creates resources required to run Storage Gateway (https://aws.amazon.com/storagegateway/) in AWS and on premises.

AWS Storage Gateway is available in 4 types :

- Amazon S3 File Gateway (FILE\_S3)
- Amazon FSx File Gateway (FILE\_FSX\_SMB)
- Tape Gateway (VTL)
- Volume Gateway (CACHED, STORED)

The module requires a Gateway type to be declared which defaults to FILE\_S3 as an example. For more details regarding the Storage Gateway types and their respective arguments can be found [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/storagegateway_gateway).

## Usage with VMware S3 File Gateway module

Link to the example : [s3filegateway-vmware](examples/s3filegateway-vmware)

### Prerequisists

- The VMware module requires the vsphere provider to be setup with the service account user name and password that has the necessary permissions in Vcenter to create a VM. This is found in the [settings.tf](examples/s3filegateway-vmware/settings.tf) file.

```hcl

provider "vsphere" {
  allow_unverified_ssl = true
  vsphere_server       = "10.0.0.10"
  user                 = "svc_terraform.domain.local"
  password             = "vcenter_password"
}

```
Note that the module requires connectivity to the vCenter server. Therefore it needs to be deployed from a virtual machine that can reach the vCenter APIs. You may also [Terraform Cloud Agents](https://developer.hashicorp.com/terraform/cloud-docs/agents) if you use already use Terrform Cloud. This allows the modules to be deployed remotely.

### [vSphere Module](modules/vmware-sgw/)

```hcl

module "vsphere" {
  source     = "aws-ia/storagegateway/aws//modules/vmware-sgw"
  datastore  = "vsan-datastore"
  datacenter = "Datacenter"
  network    = "VM Network"
  cluster    = "ESX 7.0 Cluster"
  host       = "10.0.0.2"
  name       = "my-s3fgw"
}
```
The virtual machine IP address needs to be passed to next module as the gateway IP address. In addition, the module also requires domain user name and passwords for the storage gateway to join the domain.

Note that in order to protect sensitive data such as domain credentials etc., certain variables are marked as sensitive. It is general best practice to never store credentials and secrets in git repositories. For more information about protecting sensitive variables refer to [this](https://developer.hashicorp.com/terraform/tutorials/configuration-language/sensitive-variables#reference-sensitive-variables) documentation.

Also note that the domain password despite being a sensitive vairable can be still found in the Terraform state file. Follow [this guidance](https://developer.hashicorp.com/terraform/language/state/sensitive-data) to protect state file from unauthorized access.

### [Storage Gateway Module](modules/aws-sgw/)
```hcl
module "sgw" {
  source             = "aws-ia/storagegateway/aws//modules/aws-sgw"
  name               = "my-sgw"
  gateway_ip_address = module.vsphere.vm_ip
  domain_name        = "domain.local"
  domain_username    = "domain_svc_account"
  domain_password    = "domain_svc_password"
  domain_controllers = ["10.0.0.1"]
  gateway_type       = "FILE_S3"       
}

```

## Setting up S3 buckets and SMB File Share

```hcl
module "s3_bucket" {
  source                  = "terraform-aws-modules/s3-bucket/aws"
  version                 = ">=3.5.0"
  bucket                  = "bucket-name"
  acl                     = "private"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

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
    enabled = true
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
## Support & Feedback

Storage Gateway module for Terraform is maintained by AWS Solution Architects. It is not part of an AWS service and support is provided best-effort by the AWS Storage community.

To post feedback, submit feature ideas, or report bugs, please use the Issues section of this GitHub repo.

If you are interested in contributing to the Storage Gateway module, see the Contribution guide.

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
| <a name="input_timezone"></a> [timezone](#input\_timezone) | Time zone for the gateway. The time zone is of the format GMT, GMT-hr:mm, or GMT+hr:mm. | `string` | `"GMT"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_storage_gateway"></a> [storage\_gateway](#output\_storage\_gateway) | Storage Gateway Name |
<!-- END_TF_DOCS -->
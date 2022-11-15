<!-- BEGIN_TF_DOCS -->
# AWS VMware Storage Gateway Terraform sub-module

Deployes a Storage Gateway appliance in vSphere along with cache disk.

For an end to end example on VMware, refer to the [s3filegateway-vmware](../../examples/s3filegateway-vmware/) example.

## Sizing recommendations

The defaults values are configured for a small deployment. Refer to the table below for recommendations for medium and large deployments. For more details regarding the sizing recommendations refer [here](https://docs.aws.amazon.com/storagegateway/latest/vgw/Requirements.html).

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.2.0 |
| <a name="requirement_vsphere"></a> [vsphere](#requirement\_vsphere) | >=1.25.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_vsphere"></a> [vsphere](#provider\_vsphere) | >=1.25.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [vsphere_virtual_machine.vm](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/resources/virtual_machine) | resource |
| [vsphere_compute_cluster.cluster](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/compute_cluster) | data source |
| [vsphere_datacenter.dc](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/datacenter) | data source |
| [vsphere_datastore.datastore](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/datastore) | data source |
| [vsphere_host.host](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/host) | data source |
| [vsphere_network.network](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/network) | data source |
| [vsphere_virtual_machine.aws_sg](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/virtual_machine) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster"></a> [cluster](#input\_cluster) | Cluster where the aws storage gateway will be deployed | `string` | n/a | yes |
| <a name="input_datacenter"></a> [datacenter](#input\_datacenter) | Name of the vsphere datacenter where the aws storage gateway will be deployed | `string` | n/a | yes |
| <a name="input_datastore"></a> [datastore](#input\_datastore) | Name of the vsphere datastore where the aws storage gateway will be deployed | `string` | n/a | yes |
| <a name="input_host"></a> [host](#input\_host) | Target host used during deployment of the ova | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | Name of the vsphere port group that the aws storage gateway will use | `string` | n/a | yes |
| <a name="input_cache_size"></a> [cache\_size](#input\_cache\_size) | Total size of the cache disk that will be added to the storage gateway. Specified in gigabytes. Default is set to 150 but can be increased to 64000 | `string` | `"150"` | no |
| <a name="input_cpus"></a> [cpus](#input\_cpus) | Total number of vcpus that will be configured on the storage gateway. 4 vCPU is the minimum required for a small deployment. For a medium or a large deployment increase to 8 or 16 vCPU | `string` | `"4"` | no |
| <a name="input_local_ovf_path"></a> [local\_ovf\_path](#input\_local\_ovf\_path) | Location on the local machine where the aws storage gateway ova is hosted. | `string` | `null` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Total amount of memory that will be configured on the storage gateway. Specified in megabytes. 16384 MB is the minimum required for a small deployment. For a medium or a large deployment increase to 32768 or 65536 | `string` | `"16384"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the storage gateway vm that will be created in vsphere | `string` | `"aws-storage-gateway"` | no |
| <a name="input_os_size"></a> [os\_size](#input\_os\_size) | Size of the OS disk of the appliance. Specified in gigabytes, default is the current appliance default. Likely doesn't need to be modified | `string` | `"80"` | no |
| <a name="input_provisioning_type"></a> [provisioning\_type](#input\_provisioning\_type) | Disk provisioning type for the vm and all attached disks | `string` | `"thick"` | no |
| <a name="input_remote_ovf_url"></a> [remote\_ovf\_url](#input\_remote\_ovf\_url) | URL where the aws storage gateway ova is hosted. | `string` | `"https://d28e23pnuuv0hr.cloudfront.net/aws-storage-gateway-latest.ova"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vm_ip"></a> [vm\_ip](#output\_vm\_ip) | IP address of the virtual machine |
<!-- END_TF_DOCS -->
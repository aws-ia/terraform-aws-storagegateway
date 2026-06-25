<!-- BEGIN_TF_DOCS -->
# AWS VMware Storage Gateway Terraform sub-module

Deploys a Storage Gateway in vSphere along with cache disk. The module uses the `vsphere_ovf_vm_template` data source to read OVA properties and correctly configure the guest OS type, firmware, and network mappings.

For an end to end example on VMware, refer to the [s3filegateway-vmware](../../examples/s3filegateway-vmware/) example.

## Sizing recommendations

The defaults values are configured for a small deployment. Refer to the table below for recommendations for medium and large deployments. For more details regarding the sizing recommendations refer [here](https://docs.aws.amazon.com/storagegateway/latest/vgw/Requirements.html).

## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_vsphere"></a> [vsphere](#requirement\_vsphere) | >= 2.4.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_vsphere"></a> [vsphere](#provider\_vsphere) | >= 2.4.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [vsphere_virtual_machine.vm](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/resources/virtual_machine) | resource |
| [vsphere_virtual_machine.vm_migrate](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/resources/virtual_machine) | resource |
| [vsphere_compute_cluster.cluster](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/compute_cluster) | data source |
| [vsphere_datacenter.dc](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/datacenter) | data source |
| [vsphere_datastore.datastore](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/datastore) | data source |
| [vsphere_host.host](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/host) | data source |
| [vsphere_network.network](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/network) | data source |
| [vsphere_ovf_vm_template.sgw](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/ovf_vm_template) | data source |
| [vsphere_virtual_machine.aws_sg](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/virtual_machine) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cluster"></a> [cluster](#input\_cluster) | Cluster where the aws storage gateway will be deployed | `string` | n/a | yes |
| <a name="input_datacenter"></a> [datacenter](#input\_datacenter) | Name of the vsphere datacenter where the aws storage gateway will be deployed | `string` | n/a | yes |
| <a name="input_datastore"></a> [datastore](#input\_datastore) | Name of the vsphere datastore where the aws storage gateway will be deployed | `string` | n/a | yes |
| <a name="input_host"></a> [host](#input\_host) | Target host used during deployment of the ova | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | Name of the vsphere port group that the aws storage gateway will use | `string` | n/a | yes |
| <a name="input_cache_size"></a> [cache\_size](#input\_cache\_size) | Size of the cache disk created by the OVA, in gigabytes. Only used when deployment\_option = "new-gateway". Default is 150, can be increased up to 64000. | `string` | `"150"` | no |
| <a name="input_cpus"></a> [cpus](#input\_cpus) | Total number of vcpus that will be configured on the storage gateway. 4 vCPU is the minimum required for a small deployment. For a medium or a large deployment increase to 8 or 16 vCPU | `string` | `"4"` | no |
| <a name="input_deployment_option"></a> [deployment\_option](#input\_deployment\_option) | OVF deployment option. "new-gateway" creates a fresh gateway with OS + cache disks (cache disk sized via cache\_size). "migrate" creates only the OS disk - used as the replacement VM during a method-1 migration where cache disks are attached from the source VM. | `string` | `"new-gateway"` | no |
| <a name="input_local_ovf_path"></a> [local\_ovf\_path](#input\_local\_ovf\_path) | Location on the local machine where the aws storage gateway ova is hosted. | `string` | `null` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Total amount of memory that will be configured on the storage gateway. Specified in megabytes. 16384 MB is the minimum required for a small deployment. For a medium or a large deployment increase to 32768 or 65536 | `string` | `"16384"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the storage gateway vm that will be created in vsphere | `string` | `"aws-storage-gateway"` | no |
| <a name="input_os_size"></a> [os\_size](#input\_os\_size) | Size of the OS disk in gigabytes. Default 80 (matches the v2 OVA's OS disk). Used by both "new-gateway" and "migrate" deployment options. For "migrate", set to the source gateway's OS disk size to match capacity. | `string` | `"80"` | no |
| <a name="input_provisioning_type"></a> [provisioning\_type](#input\_provisioning\_type) | Disk provisioning type for the OVF import. The v2 Storage Gateway OVA uses streamOptimized VMDKs, which can only land as "thin" during import. Disks may be inflated post-deploy if eager-zeroed thick is required. | `string` | `"thin"` | no |
| <a name="input_remote_ovf_url"></a> [remote\_ovf\_url](#input\_remote\_ovf\_url) | URL where the aws storage gateway ova is hosted. | `string` | `"https://dd958of58tzpr.cloudfront.net/aws-storage-gateway-file-s3-gateway-v2-x86_64.ova"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_deployment_option"></a> [deployment\_option](#output\_deployment\_option) | OVF deployment option used to create the VM ("new-gateway" or "migrate") |
| <a name="output_vm_id"></a> [vm\_id](#output\_vm\_id) | Managed Object ID of the storage gateway VM |
| <a name="output_vm_ip"></a> [vm\_ip](#output\_vm\_ip) | IP address of the storage gateway VM |
| <a name="output_vm_name"></a> [vm\_name](#output\_vm\_name) | Name of the storage gateway VM in vSphere |
<!-- END_TF_DOCS -->
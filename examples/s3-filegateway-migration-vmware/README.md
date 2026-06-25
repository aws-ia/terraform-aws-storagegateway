<!-- BEGIN_TF_DOCS -->
# VMware File Gateway Migration

Example demonstrates how to migrate an existing VMware-hosted S3 File Gateway to a new VM — whether your data and performance needs grow, you upgrade to a newer gateway appliance version, or refresh underlying hardware. The migration procedure preserves your cache disks and Gateway ID by following [Method 1](https://docs.aws.amazon.com/filegateway/latest/files3/migrate-data.html) from the File Gateway documentation.

## Overview

This migration method:

- Preserves cache disk data (useful for large caches or read-intensive applications)
- Maintains the same Gateway configuration (preserving the Gateway and File share IDs)
- Allows specifying CPU, memory, and disk provisioning for the new VM
- Requires 1-2 hours of downtime

The migration is split into two phases:

### Phase 1: Infrastructure Provisioning (Terraform)

Terraform deploys a new Storage Gateway VM from the official OVA alongside the existing gateway VM. The required inputs are `gateway_id` (e.g., `sgw-12A3456B`), the source VM name, and the vSphere placement (datacenter, datastore, cluster, host, network). Terraform reads the source VM's CPU, memory, and disk layout, deploys the OVA in `migrate` mode (OS disk only — no fresh cache disk), and outputs the information needed for Phase 2. Terraform does not touch the old VM or its disks — it only creates the new VM.

**Phase 1 outputs (Terraform):**

| Output | Description |
|--------|-------------|
| `migration_summary` | Combined summary: gateway ID, old/new VM names, CPU and memory, source VM disks, and vSphere placement. Marked sensitive because some fields derive from provider-marked-sensitive sources. View with `terraform output -json migration_summary`. |
| `new_gateway_ip` | IP of the new gateway VM (used by the Ansible playbook to trigger migration) |
| `new_vm_name` | vSphere name of the new gateway VM |
| `old_vm_name` | vSphere name of the source gateway VM |
| `gateway_id` | The Storage Gateway ID being migrated |
| `aws_region` | AWS region where the gateway is registered |
| `migration_url` | Pre-built HTTP URL to trigger the migration API (`http://<new_vm_ip>/migrate?gatewayId=<id>`) |
| `next_steps` | Instructions for running the Ansible playbook |

### Phase 2: Migration Execution (Ansible)

The Ansible playbook handles the actual migration: powering off the source VM, detaching its cache VMDKs (and old root VMDK), attaching them to the new VM, triggering the migration API, removing the old root VMDK after success, and waiting for the gateway to reach `RUNNING` in AWS. This separation keeps destructive vSphere operations out of Terraform and in an idempotent playbook that can be re-run if something fails mid-way (the playbook detects partial state and skips already-completed steps).

> **Important:** The playbook uses `destroy=false` when detaching VMDKs from the source VM, so the original VMDK files are preserved on the datastore. Once you have confirmed the migration is successful (see Post-Migration Validation below), you should manually delete the source VM and its preserved root VMDK to reclaim datastore space.

**Phase 2 outputs (Ansible):**

| Output | Description |
|--------|-------------|
| Migration information | Old/new VM names, gateway ID, gateway IP, and region |
| Cache dirty check | Current `CachePercentDirty` metric from CloudWatch — playbook aborts if not 0% |
| Port 80 connectivity | Reachability status of the new gateway's migration API endpoint |
| Disk classification | Breakdown of root VMDK vs cache VMDKs from the source VM |
| Recovery mode detection | Whether the playbook is resuming from a partial run (skips power-off and disk move) |
| Disk attachment results | New VM disk layout after VMDKs are reattached |
| Migration API response | Success or failure of the `http://<ip>/migrate?gatewayId=<id>` call |
| Final gateway state | AWS gateway state after migration and post-migration restart |
| SMB/AD status | Active Directory domain join status and SMB settings (if applicable) |
| Migration log | Full playbook output saved to `ansible/logs/migration-<gateway_id>-<timestamp>.log` |

## Prerequisites

Before running this example, ensure:

### Stop and prepare the source gateway

1. **Stop all applications writing to the gateway**
   - Ensure no active write operations
2. **Gateway is updated to the latest version**
   - Check in AWS Console: Storage Gateway > Gateways > Select gateway > Update Now
3. **CachePercentDirty metric is 0**
   - Check in AWS Console: Storage Gateway > Gateways > Select gateway > Monitoring tab
   - Wait for all cached data to be uploaded to S3
   - The Ansible playbook also checks this metric and aborts if it is non-zero

### Tools on the host running Terraform and Ansible

The host that runs Terraform apply and the migration playbook must have network access to vCenter (TCP 443) and to the new gateway VM (TCP 80). The migration scripts have been validated on Linux and macOS.

| Tool | Minimum version | Notes |
|------|-----------------|-------|
| Terraform | 1.5.7+ (1.10+ recommended) | Used by Phase 1 to deploy the OVA |
| Python | 3.10+ | Required by `ansible-core` and `pyVmomi` |
| `ansible-core` | 2.15+ | Install with `pip install ansible-core` |
| `pyVmomi` | latest | Install with `pip install pyvmomi` (note: import name is `pyVmomi`, install name is `pyvmomi`) |
| Ansible collection `community.vmware` | 4.0+ | Install with `ansible-galaxy collection install community.vmware` |
| Ansible collection `amazon.aws` | 8.0+ | Install with `ansible-galaxy collection install amazon.aws` |
| AWS CLI | v2 | The playbook calls `aws sts`, `aws storagegateway`, `aws cloudwatch` |
| `jq` | any | Used by helper scripts for parsing JSON |

> **Tip:** A clean Python virtual environment keeps Ansible isolated from the system Python:
>
> ```bash
> python3 -m venv ~/.ansible-venv
> source ~/.ansible-venv/bin/activate
> pip install --upgrade pip
> pip install ansible-core pyvmomi
> ansible-galaxy collection install community.vmware amazon.aws
>
```
>
> Activate the venv (`source ~/.ansible-venv/bin/activate`) in every shell that runs Terraform or Ansible against this example.

### Credentials and environment

1. **AWS credentials** with these permissions configured locally (via `aws configure`, env vars, or instance profile):
   - `storagegateway:DescribeGatewayInformation`
   - `storagegateway:DescribeSMBSettings`
   - `storagegateway:JoinDomain` (only if AD rejoin is in scope)
   - `cloudwatch:GetMetricStatistics`
   - `sts:GetCallerIdentity`
2. **vSphere service account** with permission to create VMs, attach/detach disks, and read VM info. Administrator role on the target datacenter is sufficient. The same account is used by both the Terraform provider and the Ansible playbook.
3. **vCenter is reachable on TCP 443** from the host running Terraform and Ansible.
4. **The new gateway VM will be reachable on TCP 80** from the host running Ansible (the migration API listens on port 80).

> **Security:** The migration API on the new gateway VM is plain HTTP on port 80 with no authentication. It is intended for invocation from a host on the same management network as the gateway VM and should never be exposed externally. Do not place the gateway behind a firewall rule, NAT mapping, or load balancer that allows port 80 from the public internet or untrusted networks. Once Phase 2 completes, the migration endpoint is no longer needed; restrict port 80 to the gateway's normal SMB/NFS clients only.

### Information to gather before starting

- Storage Gateway ID (e.g., `sgw-12A3456B`)
- Source VM name as it appears in vSphere (case-sensitive)
- vSphere datacenter, datastore, cluster, ESXi host, and network port group where the new VM should land
- vCenter FQDN, service account UPN, and password

## Usage

### Step 1: Configure variables

Copy the example tfvars file and edit it:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Required values (these have no defaults):

```hcl
gateway_id       = "sgw-12A3456B"
old_vm_name      = "AL2-File-Gateway"

vsphere_server   = "vcenter.example.com"
vsphere_user     = "svc-tf-sgw@vsphere.local"
vsphere_password = "<password>"

datacenter = "DC1"
datastore  = "datastore1"
cluster    = "Cluster1"
host       = "esxi-host1.example.com"
network    = "VM Network"
```

Optional overrides (defaults match the source VM where applicable):

```hcl
new_vm_name = "AL2-File-Gateway-new"   # default: "<old_vm_name>-new"
cpus        = "8"                       # default: matches source VM
memory      = "32768"                   # default: matches source VM (MB)
allow_unverified_ssl = true             # set true if vCenter cert isn't trusted
```

### Step 2: Initialize and plan

```bash
terraform init
terraform plan
```

Review the plan to confirm:

- A single new `vsphere_virtual_machine` resource will be created with `deployment_option = "migrate"`
- It will land in the datacenter/cluster/host you specified
- No inline `disk` blocks (the OVA brings its own OS disk; cache disks are added later by the playbook)

### Step 3: Apply infrastructure

```bash
terraform apply
```

This deploys the OVA, creates the new VM with one OS disk, powers it on, and waits for VMware Tools to report a guest IP. On slower vSphere environments, the OVA import and first boot can take 5–15 minutes.

If you see `context deadline exceeded` from the vSphere provider during a successful-but-slow deploy, check vCenter — the VM is likely already running and the failure is cosmetic. See **Troubleshooting** below.

### Step 4: Migration execution

After Terraform completes, the new gateway VM is running but the migration has not happened yet. Phase 2 moves the disks and triggers the migration.

```bash
cd ansible/

# Set vCenter credentials in the environment (the playbook reads them from env vars)
export VSPHERE_SERVER="$(terraform -chdir=.. output -raw vsphere_server 2>/dev/null || echo vcenter.example.com)"
export VSPHERE_USER='svc-tf-sgw@vsphere.local'
export VSPHERE_PASSWORD='<password>'
export VSPHERE_DATACENTER='DC1'
export VSPHERE_VALIDATE_CERTS=false   # if vCenter cert isn't trusted by this host

chmod +x run-migration.sh
./run-migration.sh
```

Use `./run-migration.sh --yes` to skip the interactive confirmation.

The script extracts Terraform outputs and runs the playbook. Steps the playbook performs:

1. Validate AWS credentials and look up the gateway by ARN
2. Check `CachePercentDirty` — abort if non-zero
3. Verify port 80 is reachable on the new VM
4. Discover disks on the source VM and classify root vs cache
5. Detect recovery mode (resume from a partial earlier run)
6. Power off the source VM
7. Detach all VMDKs from the source VM (cache first, then root)
8. Attach old root VMDK to the new VM at SCSI 0:1, attach cache VMDKs at SCSI 0:2+
9. Trigger migration via `http://<new_vm_ip>/migrate?gatewayId=<id>`
10. Wait for AWS to report `GatewayState = RUNNING`
11. Power off the new VM, detach the old root VMDK (no longer needed), power back on
12. Wait for the gateway to reconnect after restart
13. Report SMB/AD status (manual rejoin may be required — see Post-Migration Validation)

> **Note:** Detailed migration logs are stored in `ansible/logs/` with timestamped filenames (e.g., `migration-sgw-12A3456B-20260320_194500.log`). Review these logs for troubleshooting if the migration encounters any issues.

## Architecture

```text
┌─────────────────────────────────────────────────────────────┐
│                    Migration Process                         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Source Gateway VM (POWERED OFF)                            │
│  ┌──────────────────────────────────────┐                   │
│  │  VM: AL2-File-Gateway                │                   │
│  │  ├─ SCSI 0:0  Root VMDK ─────────┐   │                   │
│  │  ├─ SCSI 0:1  Cache VMDK 1 ─┐    │   │                   │
│  │  └─ SCSI 0:2  Cache VMDK 2 ─│─┐  │   │                   │
│  └──────────────────────────────│─│──│───┘                   │
│                                 │ │  │                       │
│                  Detach & Reattach (destroy=false)           │
│                                 │ │  │                       │
│  New Gateway VM                 │ │  │                       │
│  ┌──────────────────────────────│─│──│───┐                   │
│  │  VM: AL2-File-Gateway-new    │ │  │   │                   │
│  │  ├─ SCSI 0:0  New OS VMDK    │ │  │   │                   │
│  │  ├─ SCSI 0:1  Old Root VMDK ◄┘ │  │ * │                   │
│  │  ├─ SCSI 0:2  Cache VMDK 1 ◄───┘  │   │                   │
│  │  └─ SCSI 0:3  Cache VMDK 2 ◄──────┘   │                   │
│  └──────────────────────────────────────┘                   │
│                                                              │
│  * Old root VMDK is detached from the new VM after          │
│    migration completes; the file is preserved on the         │
│    datastore for rollback.                                   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Recommended VM sizing

For new VMware Storage Gateway deployments, use the same or larger CPU/memory than the source VM. AWS-recommended sizing:

| Workload | vCPUs | RAM |
|----------|-------|-----|
| Small | 4 | 16 GB |
| Medium | 8 | 32 GB |
| Large | 16 | 64 GB |

If `cpus` and `memory` are not specified, the new VM matches the source VM exactly.

## Terraform Outputs

After applying, view outputs with:

```bash
terraform output                          # all outputs
terraform output -json migration_summary  # the sensitive map
terraform output -raw new_gateway_ip
terraform output -raw migration_url
terraform output next_steps
```

## Post-Migration Validation

After the migration completes, verify everything is working correctly:

1. Check gateway status in the AWS Console — Storage Gateway > Gateways — confirm the gateway shows `Running`
2. Verify file shares are accessible from clients by mounting and listing files
3. Confirm cache disks are recognized — check CloudWatch `CacheUsed` and `CacheHitPercent` metrics
4. Test read/write operations on file shares to ensure data integrity
5. Monitor `CachePercentDirty` to confirm new writes are being uploaded to S3
6. **If the gateway was previously joined to Active Directory**, rejoin even if the AD status shows `JOINED`. After Method 1 migration the underlying machine identity changed:

   ```bash
   aws storagegateway join-domain \
     --gateway-arn arn:aws:storagegateway:<region>:<account>:gateway/<sgw-id> \
     --domain-name corp.example.com \
     --user-name <admin> \
     --password <password>
   ```

7. If using SMB Guest Access, re-enter the password via `aws storagegateway set-smb-guest-password`

## Old VM and Disk Cleanup

The Ansible playbook leaves the source VM powered off and preserves the old root VMDK on the datastore. This is intentional — they serve as a rollback point in case you need to investigate issues.

Once you have completed the post-migration validation steps above and are confident the migration succeeded:

```text
1. In vSphere, delete the source VM (use "Delete from Disk" to remove the
   files associated with the source VM, but the orphaned old root VMDK is
   not part of the source VM's inventory after migration).
2. In the datastore browser, delete the old root VMDK file. Its filename
   is shown in the Phase 2 final summary output.
```

You may also want to run `terraform state rm` to remove references to the source VM data lookup if you plan to re-run this example for a different gateway in the future.

## Cleanup

To remove the migration infrastructure (only if migration FAILED and you need to start over):

```bash
terraform destroy
```

Do not run `terraform destroy` after a successful migration, as it will destroy your new gateway VM.

## References

- [AWS Storage Gateway Migration Documentation](https://docs.aws.amazon.com/filegateway/latest/files3/migrate-data.html)
- [Storage Gateway Requirements](https://docs.aws.amazon.com/filegateway/latest/files3/Requirements.html)
- [VMware OVA Deployment Best Practices](https://docs.aws.amazon.com/storagegateway/latest/userguide/Requirements.html#requirements-vmware)

## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_vsphere"></a> [vsphere](#requirement\_vsphere) | >= 2.4.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.51.0 |
| <a name="provider_vsphere"></a> [vsphere](#provider\_vsphere) | 2.12.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_new_sgw"></a> [new\_sgw](#module\_new\_sgw) | ../../modules/vmware-sgw | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [vsphere_datacenter.dc](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/datacenter) | data source |
| [vsphere_virtual_machine.old_sgw](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/virtual_machine) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cluster"></a> [cluster](#input\_cluster) | Cluster where the new gateway VM will be deployed | `string` | n/a | yes |
| <a name="input_datacenter"></a> [datacenter](#input\_datacenter) | Name of the vSphere datacenter where the new gateway VM will be deployed | `string` | n/a | yes |
| <a name="input_datastore"></a> [datastore](#input\_datastore) | Name of the vSphere datastore where the new gateway VM will be deployed | `string` | n/a | yes |
| <a name="input_gateway_id"></a> [gateway\_id](#input\_gateway\_id) | The Storage Gateway ID (e.g., sgw-12A3456B) of the gateway to migrate. The vSphere VM will be automatically discovered. | `string` | n/a | yes |
| <a name="input_host"></a> [host](#input\_host) | Target ESXi host used during deployment of the OVA | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | Name of the vSphere port group that the new gateway VM will use | `string` | n/a | yes |
| <a name="input_old_vm_name"></a> [old\_vm\_name](#input\_old\_vm\_name) | Name of the existing gateway VM in vSphere to migrate from | `string` | n/a | yes |
| <a name="input_vsphere_password"></a> [vsphere\_password](#input\_vsphere\_password) | The password for the vCenter server | `string` | n/a | yes |
| <a name="input_vsphere_server"></a> [vsphere\_server](#input\_vsphere\_server) | vSphere server IP address or FQDN | `string` | n/a | yes |
| <a name="input_vsphere_user"></a> [vsphere\_user](#input\_vsphere\_user) | vSphere service account user name | `string` | n/a | yes |
| <a name="input_allow_unverified_ssl"></a> [allow\_unverified\_ssl](#input\_allow\_unverified\_ssl) | Boolean that can be set to true to disable SSL certificate verification. | `bool` | `false` | no |
| <a name="input_cpus"></a> [cpus](#input\_cpus) | Number of vCPUs for the new gateway VM. If not specified, matches the old VM. | `string` | `null` | no |
| <a name="input_gateway_type"></a> [gateway\_type](#input\_gateway\_type) | Type of the gateway. Valid options are FILE\_S3 | `string` | `"FILE_S3"` | no |
| <a name="input_local_ovf_path"></a> [local\_ovf\_path](#input\_local\_ovf\_path) | Local path to the AWS Storage Gateway OVA file. Takes precedence over remote\_ovf\_url. | `string` | `null` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Memory in MB for the new gateway VM. If not specified, matches the old VM. | `string` | `null` | no |
| <a name="input_new_vm_name"></a> [new\_vm\_name](#input\_new\_vm\_name) | Name for the new gateway VM. If not specified, uses '<old\_vm\_name>-new'. | `string` | `null` | no |
| <a name="input_remote_ovf_url"></a> [remote\_ovf\_url](#input\_remote\_ovf\_url) | URL where the AWS Storage Gateway OVA is hosted. | `string` | `"https://dd958of58tzpr.cloudfront.net/aws-storage-gateway-file-s3-gateway-v2-x86_64.ova"` | no |
| <a name="input_root_block_device"></a> [root\_block\_device](#input\_root\_block\_device) | Root (OS) disk configuration for the new gateway VM. By default the new VM's OS disk matches the source gateway VM's OS disk size so the migrated gateway has at least the same root capacity. Override per-attribute via root\_block\_device = { size = <gigabytes> }. Currently only the 'size' key is supported because the v2 OVA forces thin / non-eager-zeroed provisioning during import. | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_aws_region"></a> [aws\_region](#output\_aws\_region) | The AWS region where the gateway is registered |
| <a name="output_gateway_id"></a> [gateway\_id](#output\_gateway\_id) | The Storage Gateway ID being migrated |
| <a name="output_migration_summary"></a> [migration\_summary](#output\_migration\_summary) | Summary of the migration process. Marked sensitive because it includes fields derived from data.vsphere\_virtual\_machine.old\_sgw, which the vSphere provider treats as sensitive. Use `terraform output -json migration_summary` to view. |
| <a name="output_migration_url"></a> [migration\_url](#output\_migration\_url) | URL to initiate the gateway migration process |
| <a name="output_new_gateway_ip"></a> [new\_gateway\_ip](#output\_new\_gateway\_ip) | IP address of the new gateway VM |
| <a name="output_new_vm_name"></a> [new\_vm\_name](#output\_new\_vm\_name) | Name of the new gateway VM in vSphere |
| <a name="output_next_steps"></a> [next\_steps](#output\_next\_steps) | Next steps to complete the migration |
| <a name="output_old_vm_name"></a> [old\_vm\_name](#output\_old\_vm\_name) | Name of the old gateway VM in vSphere |
<!-- END_TF_DOCS -->
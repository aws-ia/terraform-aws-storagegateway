#!/bin/bash
################################################################################
# Storage Gateway VMware Migration Runner Script
# Extracts Terraform outputs and runs Ansible playbook
################################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

AUTO_APPROVE=false
for arg in "$@"; do
    case $arg in
        --yes|-y)
            AUTO_APPROVE=true
            shift
            ;;
    esac
done

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Storage Gateway VMware Migration Runner${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if we're in the right directory
if [ ! -f "../main.tf" ]; then
    echo -e "${RED}Error: This script must be run from the ansible/ directory${NC}"
    echo "Current directory: $(pwd)"
    exit 1
fi

# Check if Terraform has been applied
if [ ! -f "../terraform.tfstate" ]; then
    echo -e "${RED}Error: Terraform state not found. Run 'terraform apply' first.${NC}"
    exit 1
fi

echo -e "${YELLOW}Step 1: Extracting Terraform outputs...${NC}"

cd ..
export OLD_VM_NAME=$(terraform output -raw old_vm_name 2>/dev/null || echo "")
export NEW_VM_NAME=$(terraform output -raw new_vm_name 2>/dev/null || echo "")
export GATEWAY_ID=$(terraform output -raw gateway_id 2>/dev/null || echo "")
export NEW_GATEWAY_IP=$(terraform output -raw new_gateway_ip 2>/dev/null || echo "")
export AWS_REGION=$(terraform output -raw aws_region 2>/dev/null || echo "us-east-1")
cd ansible

# Check for vSphere credentials in environment
if [ -z "$VSPHERE_SERVER" ] || [ -z "$VSPHERE_USER" ] || [ -z "$VSPHERE_PASSWORD" ] || [ -z "$VSPHERE_DATACENTER" ]; then
    echo -e "${YELLOW}vSphere credentials not found in environment.${NC}"
    echo "Please set the following environment variables:"
    echo "  export VSPHERE_SERVER=<vcenter-ip-or-fqdn>"
    echo "  export VSPHERE_USER=<vcenter-username>"
    echo "  export VSPHERE_PASSWORD=<vcenter-password>"
    echo "  export VSPHERE_DATACENTER=<datacenter-name>"
    echo ""

    # Try to extract from terraform.tfvars
    if [ -f "../terraform.tfvars" ]; then
        echo -e "${YELLOW}Attempting to extract from terraform.tfvars...${NC}"
        export VSPHERE_SERVER=$(grep -E '^vsphere_server\s*=' ../terraform.tfvars | sed 's/.*=\s*"\(.*\)"/\1/' || echo "")
        export VSPHERE_DATACENTER=$(grep -E '^datacenter\s*=' ../terraform.tfvars | sed 's/.*=\s*"\(.*\)"/\1/' || echo "")
        if [ -n "$VSPHERE_SERVER" ]; then
            echo -e "${GREEN}Found vSphere server: $VSPHERE_SERVER${NC}"
        fi
        if [ -n "$VSPHERE_DATACENTER" ]; then
            echo -e "${GREEN}Found datacenter: $VSPHERE_DATACENTER${NC}"
        fi
    fi

    if [ -z "$VSPHERE_SERVER" ] || [ -z "$VSPHERE_USER" ] || [ -z "$VSPHERE_PASSWORD" ] || [ -z "$VSPHERE_DATACENTER" ]; then
        echo -e "${RED}Error: vSphere credentials are required. Set environment variables and retry.${NC}"
        exit 1
    fi
fi

# Validate required variables
if [ -z "$OLD_VM_NAME" ] || [ -z "$NEW_VM_NAME" ] || [ -z "$GATEWAY_ID" ] || [ -z "$NEW_GATEWAY_IP" ]; then
    echo -e "${RED}Error: Failed to extract required Terraform outputs${NC}"
    echo "OLD_VM_NAME: $OLD_VM_NAME"
    echo "NEW_VM_NAME: $NEW_VM_NAME"
    echo "GATEWAY_ID: $GATEWAY_ID"
    echo "NEW_GATEWAY_IP: $NEW_GATEWAY_IP"
    exit 1
fi

echo -e "${GREEN}Terraform outputs extracted${NC}"
echo "  Old VM: $OLD_VM_NAME"
echo "  New VM: $NEW_VM_NAME"
echo "  Gateway ID: $GATEWAY_ID"
echo "  Gateway IP: $NEW_GATEWAY_IP"
echo "  Region: $AWS_REGION"
echo "  vCenter: $VSPHERE_SERVER"
echo "  Datacenter: $VSPHERE_DATACENTER"
echo ""

# Check if Ansible is installed
if ! command -v ansible-playbook &> /dev/null; then
    echo -e "${RED}Error: ansible-playbook not found. Please install Ansible.${NC}"
    echo "Install with: pip install ansible"
    exit 1
fi

echo -e "${YELLOW}Step 2: Checking Ansible collections...${NC}"

if ! ansible-galaxy collection list | grep -q "community.vmware"; then
    echo -e "${YELLOW}Installing required Ansible collections...${NC}"
    ansible-galaxy collection install -r requirements.yml
else
    echo -e "${GREEN}Required collections already installed${NC}"
fi
echo ""

# Confirm before proceeding
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}WARNING: This will perform the following actions:${NC}"
echo -e "${YELLOW}========================================${NC}"
echo "1. Power off old gateway VM: $OLD_VM_NAME"
echo "2. Detach all VMDKs from old VM"
echo "3. Attach VMDKs (root + cache) to new VM: $NEW_VM_NAME"
echo "4. Trigger migration via HTTP API"
echo "5. Power cycle new VM to detach old root disk"
echo ""
echo -e "${YELLOW}The gateway will be offline during this process (1-2 hours).${NC}"
echo ""

if [ "$AUTO_APPROVE" = false ]; then
    read -p "Do you want to proceed? (yes/no): " -r
    echo
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        echo -e "${YELLOW}Migration cancelled.${NC}"
        exit 0
    fi
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Step 3: Running migration playbook...${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

LOGS_DIR="./logs"
mkdir -p "$LOGS_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$LOGS_DIR/migration-${GATEWAY_ID}-${TIMESTAMP}.log"

echo -e "${YELLOW}Migration output will be logged to: ${LOG_FILE}${NC}"
echo ""

ansible-playbook migrate.yml \
    -e "old_vm_name=$OLD_VM_NAME" \
    -e "new_vm_name=$NEW_VM_NAME" \
    -e "gateway_id=$GATEWAY_ID" \
    -e "new_gateway_ip=$NEW_GATEWAY_IP" \
    -e "aws_region=$AWS_REGION" \
    -v 2>&1 | tee "$LOG_FILE"

PLAYBOOK_EXIT_CODE=${PIPESTATUS[0]}

echo ""
if [ $PLAYBOOK_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Migration completed successfully!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${GREEN}Log file saved: ${LOG_FILE}${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Verify gateway status in AWS Console"
    echo "2. Test file share access from clients"
    echo "3. If AD-joined, re-join the domain"
    echo "4. Once verified, delete old VM: $OLD_VM_NAME"
else
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}Migration failed with exit code: $PLAYBOOK_EXIT_CODE${NC}"
    echo -e "${RED}========================================${NC}"
    echo ""
    echo -e "${RED}Log file saved: ${LOG_FILE}${NC}"
    echo ""
    echo "Check the log file for detailed error information."
    echo "The playbook supports recovery mode - re-run to resume from where it failed."
    exit $PLAYBOOK_EXIT_CODE
fi

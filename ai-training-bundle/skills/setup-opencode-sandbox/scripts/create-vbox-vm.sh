#!/usr/bin/env bash
# Create and launch a VirtualBox VM with cloud-init for opencode sandbox
# Usage: create-vbox-vm.sh --name NAME --user-data FILE [OPTIONS]
#
# Required:
#   --name NAME           VM name
#   --user-data FILE      Path to cloud-init user-data YAML
#
# Optional:
#   --cpus N              Number of CPUs (default: 2)
#   --memory MB           Memory in MB (default: 4096)
#   --disk MB             Disk size in MB (default: 20480)
#   --ubuntu-version VER  Ubuntu version (default: 24.04)
#   --ip ADDRESS          Static IP for host-only network
#   --host-adapter NAME   Host-only adapter (default: vboxnet0)
#   --working-dir DIR     Directory for VM files (default: ~/VMs)
#   --no-start            Create VM but don't start it

set -euo pipefail

# Defaults
VM_NAME=""
USER_DATA=""
CPUS=2
MEMORY=4096
DISK=20480
UBUNTU_VERSION="24.04"
IP=""
HOST_ADAPTER="vboxnet0"
WORKING_DIR="$HOME/VMs"
START_VM="true"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --name) VM_NAME="$2"; shift 2 ;;
        --user-data) USER_DATA="$2"; shift 2 ;;
        --cpus) CPUS="$2"; shift 2 ;;
        --memory) MEMORY="$2"; shift 2 ;;
        --disk) DISK="$2"; shift 2 ;;
        --ubuntu-version) UBUNTU_VERSION="$2"; shift 2 ;;
        --ip) IP="$2"; shift 2 ;;
        --host-adapter) HOST_ADAPTER="$2"; shift 2 ;;
        --working-dir) WORKING_DIR="$2"; shift 2 ;;
        --no-start) START_VM="false"; shift ;;
        -h|--help)
            cat <<EOF
Create a VirtualBox VM with cloud-init for opencode sandbox.

Usage: $(basename "$0") --name NAME --user-data FILE [OPTIONS]

Required:
  --name NAME           VM name
  --user-data FILE      Path to cloud-init user-data YAML

Optional:
  --cpus N              Number of CPUs (default: 2)
  --memory MB           Memory in MB (default: 4096)
  --disk MB             Disk size in MB (default: 20480)
  --ubuntu-version VER  Ubuntu version (default: 24.04)
  --ip ADDRESS          Static IP for host-only network
  --host-adapter NAME   Host-only adapter (default: vboxnet0)
  --working-dir DIR     Directory for VM files (default: ~/VMs)
  --no-start            Create VM but don't start it

Requirements:
  - VirtualBox with VBoxManage
  - qemu-img (for image conversion)
  - cloud-image-utils (for cloud-localds)

Example:
  $(basename "$0") --name opencode-sandbox --user-data user-data.yml --ip 192.168.56.10
EOF
            exit 0
            ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

# Validate
if [[ -z "$VM_NAME" ]]; then
    echo "Error: --name is required" >&2
    exit 1
fi
if [[ -z "$USER_DATA" ]] || [[ ! -f "$USER_DATA" ]]; then
    echo "Error: --user-data must be a valid file" >&2
    exit 1
fi

# Check dependencies
for cmd in VBoxManage qemu-img cloud-localds; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: $cmd is required but not found" >&2
        exit 1
    fi
done

# Setup directories
VM_DIR="$WORKING_DIR/$VM_NAME"
IMG_CACHE="$WORKING_DIR/.cache"
mkdir -p "$VM_DIR" "$IMG_CACHE"

# Download Ubuntu cloud image if needed
IMG_URL="https://cloud-images.ubuntu.com/releases/${UBUNTU_VERSION}/release/ubuntu-${UBUNTU_VERSION}-server-cloudimg-amd64.img"
IMG_FILE="$IMG_CACHE/ubuntu-${UBUNTU_VERSION}-server-cloudimg-amd64.img"

if [[ ! -f "$IMG_FILE" ]]; then
    echo "Downloading Ubuntu ${UBUNTU_VERSION} cloud image..."
    wget -q --show-progress -O "$IMG_FILE" "$IMG_URL"
fi

# Convert to VDI
echo "Converting image to VDI format..."
RAW_FILE="$VM_DIR/ubuntu-${UBUNTU_VERSION}.raw"
VDI_FILE="$VM_DIR/ubuntu-${UBUNTU_VERSION}.vdi"

qemu-img convert -O raw "$IMG_FILE" "$RAW_FILE"
VBoxManage convertfromraw "$RAW_FILE" "$VDI_FILE" --format VDI
rm "$RAW_FILE"

# Resize disk
echo "Resizing disk to ${DISK}MB..."
VBoxManage modifyhd "$VDI_FILE" --resize "$DISK"

# Create network config if IP specified
NETWORK_CONFIG=""
if [[ -n "$IP" ]]; then
    NETWORK_CONFIG="$VM_DIR/network-config"
    cat > "$NETWORK_CONFIG" <<EOF
version: 2
ethernets:
  enp0s3:
    dhcp4: false
    addresses:
      - ${IP}/24
EOF
fi

# Create meta-data
META_DATA="$VM_DIR/meta-data"
cat > "$META_DATA" <<EOF
instance-id: ${VM_NAME}-001
local-hostname: ${VM_NAME}
EOF

# Create seed ISO
echo "Creating cloud-init seed ISO..."
SEED_ISO="$VM_DIR/seed.iso"
if [[ -n "$NETWORK_CONFIG" ]]; then
    cloud-localds --network-config "$NETWORK_CONFIG" "$SEED_ISO" "$USER_DATA" "$META_DATA"
else
    cloud-localds "$SEED_ISO" "$USER_DATA" "$META_DATA"
fi

# Check if VM already exists
if VBoxManage showvminfo "$VM_NAME" &>/dev/null; then
    echo "Error: VM '$VM_NAME' already exists" >&2
    echo "To delete: VBoxManage unregistervm '$VM_NAME' --delete" >&2
    exit 1
fi

# Create VM
echo "Creating VM '$VM_NAME'..."
VBoxManage createvm --name "$VM_NAME" --ostype Ubuntu_64 --register --basefolder "$WORKING_DIR"

# Configure VM
VBoxManage modifyvm "$VM_NAME" \
    --cpus "$CPUS" \
    --memory "$MEMORY" \
    --acpi on \
    --boot1 disk \
    --boot2 dvd \
    --nic1 hostonly \
    --hostonlyadapter1 "$HOST_ADAPTER" \
    --nic2 nat \
    --natpf2 "ssh,tcp,,2222,,22"

# Enable nested virtualization (useful for containers)
VBoxManage modifyvm "$VM_NAME" --nested-hw-virt on

# Add storage controllers
VBoxManage storagectl "$VM_NAME" --name "SATA" --add sata --controller IntelAhci --portcount 2
VBoxManage storagectl "$VM_NAME" --name "IDE" --add ide --controller PIIX4

# Attach disk and seed ISO
VBoxManage storageattach "$VM_NAME" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "$VDI_FILE"
VBoxManage storageattach "$VM_NAME" --storagectl "IDE" --port 1 --device 0 --type dvddrive --medium "$SEED_ISO"

echo "VM '$VM_NAME' created successfully"
echo "  VDI: $VDI_FILE"
echo "  Seed ISO: $SEED_ISO"

# Start VM if requested
if [[ "$START_VM" == "true" ]]; then
    echo "Starting VM..."
    VBoxManage startvm "$VM_NAME" --type headless
    
    echo ""
    echo "VM is starting. Cloud-init will configure the system on first boot."
    echo ""
    if [[ -n "$IP" ]]; then
        echo "Once ready, connect with: ssh -o StrictHostKeyChecking=no USER@${IP}"
    else
        echo "Connect via NAT port forward: ssh -o StrictHostKeyChecking=no -p 2222 USER@localhost"
    fi
    echo ""
    echo "To check cloud-init status:"
    echo "  ssh USER@HOST 'cloud-init status --wait'"
    echo ""
    echo "To stop the VM:"
    echo "  VBoxManage controlvm '$VM_NAME' poweroff"
fi

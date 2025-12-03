# Single VM Provisioning

Create virtual machines in Proxmox using OpenTofu.

## Requirements

- OpenTofu >= 1.10.0
- Proxmox VE >= 9.x
- Cloud-init template
- Proxmox API token

## Creating a Cloud-init Template

Run on any Proxmox node:

```bash
export PROXMOX_STORAGE=compute-storage

apt update && apt install libguestfs-tools -y

wget --backups=1 https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img

virt-customize -a jammy-server-cloudimg-amd64.img --install qemu-guest-agent

qm create 700 \
  --name "ubuntu-22.04-cloudinit-template" \
  --cores 2 \
  --memory 2048 \
  --net0 virtio,bridge=vmbr0 \
  --scsihw virtio-scsi-pci

qm set 700 --virtio0 ${PROXMOX_STORAGE}:0,import-from=/root/jammy-server-cloudimg-amd64.img
qm set 700 --ide2 ${PROXMOX_STORAGE}:cloudinit
qm set 700 --boot order=virtio0
qm set 700 --serial0 socket --vga serial0

qm template 700
```

Or use the script from `../../proxmox-scripts/create-ubuntu-template.sh`

## Configuration

```bash
# Copy the example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit for your environment
vim terraform.tfvars
```

Required changes:
- `virtual_environment_endpoint` — Proxmox address
- `virtual_environment_api_token` — API token
- `ssh_public_key` — SSH key

## Creating an API Token in Proxmox

Via WebUI:
```
Datacenter → Permissions → API Tokens → Add
```

Or via CLI on the node:
```bash
pveum user token add root@pam terraform -privsep 0
```

Required permissions: `PVEVMAdmin`, `PVEDatastoreUser`

## Usage

```bash
tofu init     # Download providers
tofu plan     # Preview what will be created
tofu apply    # Create VMs
tofu destroy  # Delete VMs
```

## Output

After `tofu apply` you'll see:

```hcl
vm_info = {
  "vm-01" = {
    "id"     = "pve-compute-01/qemu/100"
    "ipv4"   = "192.168.1.100"
    "node"   = "pve-compute-01"
    "status" = "running"
  }
}

ssh_commands = {
  "vm-01" = "ssh infra@192.168.1.100"
}
```

## Main Parameters

Configured in `terraform.tfvars`:

| Parameter | Default | Description |
|-----------|---------|-------------|
| `vm_count` | 1 | Number of VMs to create |
| `vm_cpu_cores` | 2 | CPU cores |
| `vm_memory_mb` | 2048 | RAM in megabytes |
| `vm_disk_size_gb` | 40 | Disk size |
| `template_id` | 700 | Template ID for cloning |
| `datastore_id` | compute-storage | Disk storage location |

## Troubleshooting

**VM doesn't get an IP:**
- Check that DHCP is working in the network
- Ensure qemu-guest-agent is installed in the template
- Wait a minute or two — the agent doesn't start instantly

**Template won't clone:**
- `qm list` — verify the template exists
- Make sure it's on the required node
- Check API token permissions

**API connection error:**
- `curl -k https://your-proxmox:8006/api2/json/version`
- Verify the API token
- Check firewall rules

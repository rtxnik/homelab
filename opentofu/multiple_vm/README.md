# Multiple VM Provisioning

Deploy multiple virtual machines in Proxmox with individual parameters for each VM.

## Differences from single_vm

- Fixed VM IDs for each machine
- Static IP addresses instead of DHCP
- Individual CPU/RAM configuration for each VM
- Uses `for_each` instead of `count` for flexible management
- VM grouping by node in outputs

## Requirements

- OpenTofu >= 1.10.0
- Proxmox VE >= 9.x
- Cloud-init template (ID 700 by default)
- Proxmox API token
- Configured network with gateway

## VM Configuration Structure

Each VM is described in `terraform.tfvars` as an object with parameters:

```hcl
"vm-name" = {
  vm_id       = 121              # Fixed ID in Proxmox
  name        = "vm-01-small"    # VM name
  node        = "pve-compute-01" # Node for placement
  ip_address  = "10.0.10.21"     # Static IP
  cpu_cores   = 2                # Number of CPU cores
  memory_mb   = 4096             # RAM in megabytes
  description = "..."            # Description
  tags        = ["small"]        # Additional tags
}
```

## Example Configuration

The `terraform.tfvars.example` contains 6 VMs:

### pve-compute-01
- **vm-01-small** (ID 121): 10.0.10.21, 2 CPU, 4GB RAM
- **vm-01-large** (ID 131): 10.0.10.31, 4 CPU, 8GB RAM

### pve-compute-02
- **vm-02-small** (ID 122): 10.0.10.22, 2 CPU, 4GB RAM
- **vm-02-large** (ID 132): 10.0.10.32, 4 CPU, 8GB RAM

### pve-compute-03
- **vm-03-small** (ID 123): 10.0.10.23, 2 CPU, 4GB RAM
- **vm-03-large** (ID 133): 10.0.10.33, 4 CPU, 8GB RAM

## Setup

```bash
# Copy the example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit for your infrastructure
vim terraform.tfvars
```

### Required configuration:

1. **Proxmox API:**
   ```hcl
   virtual_environment_endpoint  = "https://192.168.1.10:8006"
   virtual_environment_api_token = "root@pam!terraform=..."
   ```

2. **SSH key:**
   ```hcl
   ssh_public_key = "ssh-ed25519 AAAA..."
   ```

3. **Network:**
   ```hcl
   network_gateway = "10.0.10.1"      # Your network gateway
   network_cidr    = 24               # Subnet mask
   dns_servers     = ["8.8.8.8", "1.1.1.1"]
   ```

4. **VM configuration:**
   - Edit the `vms` block for your needs
   - Ensure IP addresses don't conflict
   - Verify VM IDs are available

## Usage

```bash
# Initialize
tofu init

# Preview the plan
tofu plan

# Create all VMs
tofu apply

# Create a specific VM
tofu apply -target='proxmox_virtual_environment_vm.vm["vm-01-small"]'

# Delete a specific VM
tofu destroy -target='proxmox_virtual_environment_vm.vm["vm-01-small"]'

# Delete all VMs
tofu destroy
```

## Output Information

After `tofu apply` you'll get:

```hcl
# Detailed information about each VM
vm_info = {
  "vm-01-small" = {
    cpu_cores  = 2
    id         = "pve-compute-01/qemu/121"
    ip_static  = "10.0.10.21"
    memory_mb  = 4096
    name       = "vm-01-small"
    node       = "pve-compute-01"
    status     = "running"
    vm_id      = 121
  }
  # ... other VMs
}

# VMs grouped by node
vms_by_node = {
  "pve-compute-01" = [
    {
      cpu_cores  = 2
      ip_address = "10.0.10.21"
      memory_mb  = 4096
      name       = "vm-01-small"
      vm_id      = 121
    },
    # ...
  ]
  # ... other nodes
}

# SSH commands for connection
ssh_commands = {
  "vm-01-small" = "ssh infra@10.0.10.21"
  "vm-01-large" = "ssh infra@10.0.10.31"
  # ...
}
```

## Configuration Management

### Adding a New VM

Add a block to `terraform.tfvars`:

```hcl
"vm-04-custom" = {
  vm_id       = 140
  name        = "vm-04-custom"
  node        = "pve-compute-01"
  ip_address  = "10.0.10.40"
  cpu_cores   = 8
  memory_mb   = 16384
  description = "Custom VM"
  tags        = ["custom", "high-performance"]
}
```

Then run `tofu apply`.

### Modifying an Existing VM

Change the parameters in `terraform.tfvars` and run `tofu apply`.

**Warning:** Some parameter changes require VM recreation:
- `vm_id` — recreation required
- `node` — recreation required
- `ip_address` — can be changed without recreation
- `cpu_cores`, `memory_mb` — can be changed without recreation

### Deleting a VM

Remove the block from `terraform.tfvars` and run `tofu apply`, or use `-target` for targeted deletion.

## Network Requirements

For static IP addresses you need:

1. **Configured subnet:** IP addresses must be in the correct subnet
2. **Gateway:** The specified gateway must be accessible
3. **Free IPs:** Ensure IPs aren't used by other devices
4. **VLAN (if used):** Properly configured bridge in Proxmox

## Pre-creation Verification

```bash
# Check available VM IDs
for node in pve-compute-01 pve-compute-02 pve-compute-03; do
  echo "=== $node ==="
  ssh root@$node "qm list | grep -E '(121|131|122|132|123|133)'"
done

# Check IP address availability
for ip in 10.0.10.{21,31,22,32,23,33}; do
  echo -n "Testing $ip: "
  ping -c 1 -W 1 $ip >/dev/null 2>&1 && echo "USED" || echo "FREE"
done

# Check gateway availability
ping -c 3 10.0.10.1
```

## Common Issues

### VM ID Already Taken

```
Error: VM with ID 121 already exists
```

**Solution:** Choose a different ID or delete the existing VM:
```bash
ssh root@pve-compute-01 "qm destroy 121"
```

### IP Address Already in Use

No connectivity after VM creation — possible IP conflict.

**Solution:**
- Check `arp -a` on another host in the network
- Use a different IP address

### VM Doesn't Get IP

Cloud-init isn't applying configuration.

**Solution:**
- Ensure the template contains a `cloud-init` disk
- Check that `cloud-init` package is installed in the template
- Check logs: `journalctl -u cloud-init`

### Gateway Unreachable

VM is created but has no external connectivity.

**Solution:**
- Verify the gateway exists and is accessible
- Check VLAN configuration
- Check firewall rules in OPNsense

## Advanced Usage

### Creating VMs with Different Disk Sizes

To change `vm_disk_size_gb` per VM, you'll need to modify `main.tf` to include disk size in the VM configuration.

### Using Different Templates

You can create multiple configurations with different templates for different VM types (Ubuntu, Debian, Rocky Linux).

### Ansible Integration

After creating VMs, use the `ssh_commands` output to generate Ansible inventory:

```bash
tofu output -json ssh_commands | jq -r 'to_entries[] | "\(.key) ansible_host=\(.value | split("@")[1])"'
```

## Next Steps

After deploying VMs:

1. **Verify connection:** `ssh infra@10.0.10.21`
2. **Install updates:** `sudo apt update && sudo apt upgrade -y`
3. **Set up monitoring:** Prometheus node_exporter
4. **Add to Ansible inventory**
5. **Configure backup**

## See Also

- [../single_vm/README.md](../single_vm/README.md) — Basic configuration for a single VM
- [../../proxmox-scripts/README.md](../../proxmox-scripts/README.md) — Proxmox scripts

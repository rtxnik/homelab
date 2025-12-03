# Proxmox Scripts

Utilities for working with a Proxmox cluster.

## create-ubuntu-template.sh

Creates an Ubuntu 22.04 cloud-init template for Proxmox.

## create-rocky9-template.sh

Creates a Rocky Linux 9 cloud-init template for Proxmox.

**Usage:**
```bash
# On a Proxmox node
./create-ubuntu-template.sh [TEMPLATE_ID] [STORAGE]
./create-rocky9-template.sh [TEMPLATE_ID] [STORAGE]

# Example
./create-ubuntu-template.sh 700 compute-storage
./create-rocky9-template.sh 701 compute-storage
```

**What it does:**
- Downloads cloud image
- Installs qemu-guest-agent
- Creates VM and configures it
- Converts to template

**Requirements:**
- Proxmox VE 9.x
- Root access
- Internet connection

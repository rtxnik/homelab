variable "vms" {
  description = "Map of VMs to create with their configurations"
  type = map(object({
    vm_id       = number
    name        = string
    node        = string
    ip_address  = string
    cpu_cores   = number
    memory_mb   = number
    description = string
    tags        = optional(list(string), [])
  }))
}

variable "template_id" {
  description = "Template VM ID to clone"
  type        = number
  default     = 700
}

variable "template_node" {
  description = "Node where template is located"
  type        = string
  default     = "pve-compute-01"
}

variable "vm_cpu_type" {
  description = "CPU type"
  type        = string
  default     = "x86-64-v2-AES"
}

variable "vm_disk_size_gb" {
  description = "Disk size in GB (same for all VMs)"
  type        = number
  default     = 20
}

variable "datastore_id" {
  description = "Datastore for VM disks"
  type        = string
  default     = "compute-storage"
}

variable "network_bridge" {
  description = "Network bridge"
  type        = string
  default     = "vmbr0"
}

variable "network_cidr" {
  description = "Network CIDR prefix (e.g., 24 for /24)"
  type        = number
  default     = 24
}

variable "network_gateway" {
  description = "Default gateway for VMs"
  type        = string
}

variable "dns_servers" {
  description = "DNS servers for VMs"
  type        = list(string)
  default     = ["10.0.10.1", "10.0.20.11"]
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
  sensitive   = true
}

variable "virtual_environment_endpoint" {
  description = "Proxmox API endpoint"
  type        = string
}

variable "virtual_environment_api_token" {
  description = "Proxmox API token"
  type        = string
  sensitive   = true
}

variable "common_tags" {
  description = "Common tags to apply to all VMs"
  type        = list(string)
  default     = ["opentofu", "automated", "multiple-vm"]
}

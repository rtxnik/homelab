variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 1

  validation {
    condition     = var.vm_count > 0 && var.vm_count <= 10
    error_message = "vm_count must be between 1 and 10"
  }
}

variable "vm_name_prefix" {
  description = "Prefix for VM names"
  type        = string
  default     = "vm"
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

variable "vm_cpu_cores" {
  description = "Number of CPU cores per VM"
  type        = number
  default     = 2
}

variable "vm_cpu_type" {
  description = "CPU type"
  type        = string
  default     = "x86-64-v2-AES"
}

variable "vm_memory_mb" {
  description = "Memory in MB"
  type        = number
  default     = 2048
}

variable "vm_disk_size_gb" {
  description = "Disk size in GB"
  type        = number
  default     = 40
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

variable "dns_servers" {
  description = "DNS servers for VMs"
  type        = list(string)
  default     = ["192.168.1.1", "8.8.8.8"]
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

variable "vm_tags" {
  description = "Tags to apply to VMs"
  type        = list(string)
  default     = ["opentofu", "automated"]
}

variable "cluster_nodes" {
  description = "List of cluster nodes"
  type        = list(string)
  default     = ["pve-compute-01", "pve-compute-02", "pve-compute-03"]
}

resource "proxmox_virtual_environment_vm" "vm" {
  for_each = var.vms

  vm_id       = each.value.vm_id
  name        = each.value.name
  node_name   = each.value.node
  description = "Managed by OpenTofu - ${each.value.description}"
  tags        = concat(var.common_tags, try(each.value.tags, []))
  on_boot     = true
  migrate     = true

  clone {
    vm_id     = var.template_id
    node_name = var.template_node
    retries   = 3
    full      = true
  }

  agent {
    enabled = true
    timeout = "60s"
  }

  cpu {
    cores = each.value.cpu_cores
    type  = var.vm_cpu_type
  }

  memory {
    dedicated = each.value.memory_mb
  }

  vga {
    type = "virtio"
  }

  serial_device {}

  disk {
    size         = var.vm_disk_size_gb
    interface    = "virtio0"
    datastore_id = var.datastore_id
    file_format  = "raw"
    iothread     = true
    discard      = "on"
  }

  network_device {
    bridge = var.network_bridge
    model  = "virtio"
    mtu    = 1500
    queues = each.value.cpu_cores
  }

  initialization {
    datastore_id = var.datastore_id

    ip_config {
      ipv4 {
        address = "${each.value.ip_address}/${var.network_cidr}"
        gateway = var.network_gateway
      }
    }

    dns {
      servers = var.dns_servers
    }

    user_account {
      username = "infra"
      keys     = [var.ssh_public_key]
    }
  }

  lifecycle {
    ignore_changes = [
      description,
    ]
  }
}

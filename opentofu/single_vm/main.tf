locals {
  # Распределение VM по нодам кластера
  node_count = length(var.cluster_nodes)
  
  # Динамические теги с датой создания
  vm_tags = concat(
    var.vm_tags,
    [formatdate("YYYY-MM", timestamp())]
  )
}

resource "proxmox_virtual_environment_vm" "vm" {
  count = var.vm_count

  name        = format("%s-%02d", var.vm_name_prefix, count.index + 1)
  node_name   = var.cluster_nodes[count.index % local.node_count]
  description = "Managed by OpenTofu - Created: ${formatdate("YYYY-MM-DD", timestamp())}"
  tags        = local.vm_tags
  on_boot     = true
  migrate     = true

  clone {
    vm_id     = var.template_id
    node_name = var.template_node
    retries   = 3
    full      = false  # Linked clone для экономии места
  }

  agent {
    enabled = true
    timeout = "60s"
  }

  cpu {
    cores = var.vm_cpu_cores
    type  = var.vm_cpu_type
  }

  memory {
    dedicated = var.vm_memory_mb
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
    queues = var.vm_cpu_cores
  }

  initialization {
    datastore_id = var.datastore_id

    ip_config {
      ipv4 {
        address = "dhcp"
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

  timeouts {
    create = "10m"
    update = "10m"
    delete = "5m"
  }
}

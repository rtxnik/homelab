output "vm_info" {
  description = "Information about created VMs"
  value = {
    for key, vm in proxmox_virtual_environment_vm.vm : key => {
      id          = vm.id
      vm_id       = vm.vm_id
      name        = vm.name
      node        = vm.node_name
      ip_static   = var.vms[key].ip_address
      cpu_cores   = var.vms[key].cpu_cores
      memory_mb   = var.vms[key].memory_mb
      status      = vm.started ? "running" : "stopped"
    }
  }
}

output "vms_by_node" {
  description = "VMs grouped by node"
  value = {
    for node in distinct([for k, v in var.vms : v.node]) :
    node => [
      for key, vm_config in var.vms :
      {
        name       = vm_config.name
        vm_id      = vm_config.vm_id
        ip_address = vm_config.ip_address
        cpu_cores  = vm_config.cpu_cores
        memory_mb  = vm_config.memory_mb
      }
      if vm_config.node == node
    ]
  }
}

output "ssh_commands" {
  description = "SSH commands to connect to VMs"
  value = {
    for key, vm_config in var.vms :
    vm_config.name => "ssh infra@${vm_config.ip_address}"
  }
}

output "vm_ids_map" {
  description = "Map of VM names to VM IDs"
  value = {
    for key, vm in proxmox_virtual_environment_vm.vm :
    vm.name => vm.vm_id
  }
}

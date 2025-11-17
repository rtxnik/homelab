output "vm_info" {
  description = "Information about created VMs"
  value = {
    for idx, vm in proxmox_virtual_environment_vm.vm : vm.name => {
      id     = vm.id
      node   = vm.node_name
      ipv4   = try(vm.ipv4_addresses[1][0], "pending")
      mac    = try(vm.mac_addresses[0], "")
      status = vm.started ? "running" : "stopped"
    }
  }
}

output "vm_ids" {
  description = "Map of VM names to IDs"
  value       = { for vm in proxmox_virtual_environment_vm.vm : vm.name => vm.id }
}

output "ssh_commands" {
  description = "SSH commands to connect to VMs"
  value = {
    for vm in proxmox_virtual_environment_vm.vm :
    vm.name => "ssh infra@${try(vm.ipv4_addresses[1][0], "pending")}"
  }
}

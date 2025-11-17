# Single VM Provisioning

Создание виртуальных машин в Proxmox через OpenTofu.

## Что нужно

- OpenTofu >= 1.10.0
- Proxmox VE >= 9.x
- Cloud-init template
- API token для Proxmox

## Создание cloud-init template

Запустить на любой ноде Proxmox:

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

Или использовать скрипт из `../../scripts/create-ubuntu-template.sh`

## Настройка

```bash
# Скопировать пример переменных
cp terraform.tfvars.example terraform.tfvars

# Отредактировать под задачу
vim terraform.tfvars
```

Что точно нужно поменять:
- `virtual_environment_endpoint` - адрес Proxmox
- `virtual_environment_api_token` - API token
- `ssh_public_key` - SSH ключ

## API token в Proxmox

Создать через WebUI:
```
Datacenter → Permissions → API Tokens → Add
```

Или в CLI на ноде:
```bash
pveum user token add root@pam terraform -privsep 0
```

Нужные права: `PVEVMAdmin`, `PVEDatastoreUser`

## Использование

```bash
tofu init     # Скачать провайдеры
tofu plan     # Посмотреть что будет создано
tofu apply    # Создать VM
tofu destroy  # Удалить VM
```

## Что получим

После `tofu apply` увидим:

```
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

## Основные параметры

Настраивается в `terraform.tfvars`:

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `vm_count` | 1 | Сколько VM создать |
| `vm_cpu_cores` | 2 | Ядер CPU |
| `vm_memory_mb` | 2048 | RAM в мегабайтах |
| `vm_disk_size_gb` | 40 | Размер диска |
| `template_id` | 700 | ID template для клонирования |
| `datastore_id` | compute-storage | Где хранить диски |

## Если что-то не работает

**VM не получает IP:**
- Проверить что DHCP работает в сети
- Убедиться что qemu-guest-agent установлен в template
- Подождать минуту-две, агент запускается не мгновенно

**Не клонируется template:**
- `qm list` - проверить что template существует
- Убедиться что он на нужной ноде
- Проверить права API token

**Ошибка подключения к API:**
- `curl -k https://твой-proxmox:8006/api2/json/version`
- Проверить API token
- Посмотреть firewall правила

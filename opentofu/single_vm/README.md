# Proxmox Single VM Provisioning

Автоматическое создание виртуальных машин в Proxmox кластере через OpenTofu.

## Требования

- OpenTofu >= 1.6.0
- Proxmox VE 8.x
- Подготовленный cloud-init template (см. ниже)
- API token для Proxmox

## Подготовка cloud-init template

Запусти команды на одной из нод Proxmox:

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

После этого template с ID 700 будет доступен для клонирования.

> **Примечание:** Для автоматизации создания templates используй скрипты из репозитория [proxmox-scripts](https://github.com/yourusername/proxmox-scripts)

## Настройка

1. Скопируй пример конфига:
```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Отредактируй `terraform.tfvars`:
```hcl
virtual_environment_endpoint  = "https://192.168.1.10:8006"
virtual_environment_api_token = "root@pam!terraform=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
ssh_public_key               = "ssh-ed25519 AAAA..."

vm_count      = 1
vm_name_prefix = "vm"
vm_cpu_cores  = 2
vm_memory_mb  = 2048
```

## Создание API token в Proxmox

```bash
# В Proxmox WebUI:
# Datacenter → Permissions → API Tokens → Add

# Или через CLI на ноде:
pveum user token add root@pam terraform -privsep 0
```

Необходимые права:
- `PVEVMAdmin` - управление VM
- `PVEDatastoreUser` - доступ к хранилищу

## Использование

```bash
# Инициализация
tofu init

# Проверка плана
tofu plan

# Применение
tofu apply

# Удаление всех VM
tofu destroy
```

## Outputs

После `tofu apply` получишь:

```
vm_info = {
  "vm-01" = {
    "id" = "pve-compute-01/qemu/100"
    "ipv4" = "192.168.1.100"
    "node" = "pve-compute-01"
    "status" = "running"
  }
}

ssh_commands = {
  "vm-01" = "ssh infra@192.168.1.100"
}
```

## Параметры

Основные переменные в `variables.tf`:

| Переменная | Описание | Значение по умолчанию |
|-----------|----------|---------------------|
| `vm_count` | Количество VM | 1 |
| `vm_cpu_cores` | CPU cores | 2 |
| `vm_memory_mb` | RAM в MB | 2048 |
| `vm_disk_size_gb` | Диск в GB | 40 |
| `template_id` | ID template | 700 |
| `datastore_id` | Хранилище | compute-storage |

## Структура проекта

```
single_vm/
├── .gitignore              # Git ignore правила
├── README.md               # Документация
├── main.tf                 # Основные ресурсы
├── variables.tf            # Переменные
├── outputs.tf              # Выходные данные
├── providers.tf            # Настройка провайдера
├── versions.tf             # Версии
└── terraform.tfvars.example # Пример конфига
```

## Troubleshooting

### VM не получает IP
- Проверь DHCP сервер в сети
- Убедись что qemu-guest-agent установлен в template
- Подожди 1-2 минуты после создания VM

### Ошибка клонирования template
- Убедись что template существует: `qm list`
- Проверь что template на правильной ноде
- Проверь права API token

### Ошибка подключения к Proxmox API
- Проверь endpoint: `curl -k https://your-proxmox:8006/api2/json/version`
- Проверь API token
- Проверь сетевую доступность

## TODO

- [ ] Поддержка статических IP адресов
- [ ] Интеграция с Ansible для post-provisioning
- [ ] Поддержка cloud-config файлов
- [ ] Мониторинг создания VM

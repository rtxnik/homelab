# Homelab Infrastructure

Конфигурации для автоматизации домашнего кластера Proxmox через OpenTofu.

## Что тут есть

**Железо:**
- 3x HP Elite Mini 800 G9 в кластере
- Ceph для распределенного хранилища
- 5 VLAN'ов (Management, Services, Storage, IoT, DMZ)
- OPNsense как файрвол
- MikroTik CSS318 + Kinetic для коммутации

**Софт:**
- `opentofu/single_vm/` - создание VM в Proxmox
- `scripts/` - утилиты для работы с кластером

## Как пользоваться

```bash
git clone https://github.com/rtxnik/homelab.git
cd homelab/opentofu/single_vm

# Настроить свои параметры
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars

# Запустить
tofu init
tofu plan
tofu apply
```

Подробности в [opentofu/single_vm/README.md](opentofu/single_vm/README.md)

## Требования

- OpenTofu >= 1.10.0
- Proxmox VE 9.x
- API token для Proxmox
- Cloud-init template (инструкции в README)

## Скрипты

В `scripts/` лежат утилиты для Proxmox:
- `create-ubuntu-template.sh` - создание Ubuntu cloud-init template

## License

MIT

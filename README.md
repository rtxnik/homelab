# Homelab Infrastructure

Автоматизация инфраструктуры домашней лаборатории с использованием OpenTofu.

## Инфраструктура

**Кластер Proxmox:**
- 3x HP Elite Mini 800 G9
- Ceph Storage (distributed)
- Network: 5 VLANs (Management, Services, Storage, IoT, DMZ)
- Firewall: OPNsense
- Switches: MikroTik CSS318 + Kinetic

## Структура

```
homelab/
├── opentofu/           # Infrastructure as Code
│   └── single_vm/     # Создание VM в Proxmox
└── README.md
```

## OpenTofu конфигурации

### single_vm
Автоматическое создание виртуальных машин в Proxmox кластере.

Подробнее: [opentofu/single_vm/README.md](opentofu/single_vm/README.md)

## Требования

- OpenTofu >= 1.6.0
- Proxmox VE 8.x с подготовленным cloud-init template
- API token для Proxmox

## Быстрый старт

```bash
# Clone репозитория
git clone https://github.com/yourusername/homelab.git
cd homelab/opentofu/single_vm

# Настройка
cp terraform.tfvars.example terraform.tfvars
# Отредактируй terraform.tfvars

# Запуск
tofu init
tofu plan
tofu apply
```

## Связанные репозитории

- **proxmox-scripts** - утилиты для Proxmox (создание templates, мониторинг, бэкапы)

## TODO

- [ ] Kubernetes cluster deployment
- [ ] GitOps с ArgoCD
- [ ] Мониторинг (Prometheus/Grafana)
- [ ] Ansible интеграция для post-provisioning

## License

MIT

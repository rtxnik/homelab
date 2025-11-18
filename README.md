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
- `opentofu/single_vm/` - создание одной или нескольких одинаковых VM
- `opentofu/multiple_vm/` - создание нескольких VM с индивидуальными параметрами
- `proxmox-scripts/` - утилиты для работы с кластером

## Конфигурации OpenTofu

### single_vm
Базовая конфигурация для развертывания одной или нескольких идентичных VM с автоматическим распределением по нодам.

**Особенности:**
- DHCP для получения IP адресов
- Автоматическая нумерация VM ID
- Одинаковые параметры CPU/RAM для всех VM

**Использование:**
```bash
cd opentofu/single_vm
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars  # настроить vm_count и параметры
tofu init && tofu apply
```

Подробности: [opentofu/single_vm/README.md](opentofu/single_vm/README.md)

### multiple_vm
Продвинутая конфигурация для развертывания нескольких VM с индивидуальными параметрами.

**Особенности:**
- Статические IP адреса для каждой VM
- Фиксированные VM ID
- Индивидуальная конфигурация CPU/RAM/тегов
- Явное указание ноды для размещения
- Использование `for_each` для гибкого управления

**Пример использования:**
```bash
cd opentofu/multiple_vm
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars  # настроить блок vms
tofu init && tofu apply
```

**Пример конфигурации VM:**
```hcl
vms = {
	"vm-01-small" = {
		vm_id       = 121
		name        = "vm-01-small"
		node        = "pve-compute-01"
		ip_address  = "10.0.10.21"
		cpu_cores   = 2
		memory_mb   = 4096
		description = "Small VM"
		tags        = ["small"]
	}
	# ... больше VM
}
```

Подробности: [opentofu/multiple_vm/README.md](opentofu/multiple_vm/README.md)

## Сравнение конфигураций

| Параметр | single_vm | multiple_vm |
|----------|-----------|-------------|
| IP адреса | DHCP | Статические |
| VM ID | Автоматические | Фиксированные |
| Параметры | Одинаковые | Индивидуальные |
| Управление | `count` | `for_each` |
| Использование | Быстрое создание | Точная настройка |

## Требования

- OpenTofu >= 1.10.x
- Proxmox VE 9.x
- API token для Proxmox
- Cloud-init template (инструкции в README конфигураций)

## Быстрый старт

```bash
# Клонировать репозиторий
git clone https://github.com/rtxnik/homelab.git
cd homelab

# Создать cloud-init template на Proxmox ноде
ssh root@pve-compute-01 'bash -s' < proxmox-scripts/create-ubuntu-template.sh

# Выбрать нужную конфигурацию
cd opentofu/single_vm    # или multiple_vm

# Настроить параметры
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars

# Развернуть VM
tofu init
tofu plan
tofu apply
```

## Скрипты

В `proxmox-scripts/` лежат утилиты для Proxmox:
- `create-ubuntu-template.sh` - создание Ubuntu 22.04 cloud-init template

## Структура репозитория

```
homelab/
├── README.md
├── LICENSE
├── .gitignore
├── .gitmessage
├── opentofu/
│   ├── single_vm/
│   │   ├── README.md
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── providers.tf
│   │   ├── versions.tf
│   │   └── terraform.tfvars.example
│   └── multiple_vm/
│       ├── README.md
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── providers.tf
│       ├── versions.tf
│       └── terraform.tfvars.example
└── proxmox-scripts/
		├── README.md
		└── create-ubuntu-template.sh
```

## Следующие шаги

1. **Kubernetes кластер:** Использовать multiple_vm для создания master/worker нод
2. **Ansible интеграция:** Автоматическая генерация inventory из OpenTofu outputs
3. **Мониторинг:** Prometheus/Grafana stack на отдельных VM
4. **Storage:** Longhorn для persistent volumes в Kubernetes

## License

MIT

---

**Полезные ссылки:**
- [Proxmox VE Documentation](https://pve.proxmox.com/wiki/Main_Page)
- [OpenTofu Documentation](https://opentofu.org/docs/)
- [bpg/proxmox Provider](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)

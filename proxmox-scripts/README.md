# Proxmox Scripts

Утилиты для работы с Proxmox кластером.

## create-ubuntu-template.sh

Создает Ubuntu 22.04 cloud-init template для Proxmox.

## create-rocky9-template.sh

Создает Rocky Linux 9  cloud-init template для Proxmox.

**Использование:**
```bash
# На Proxmox ноде
./create-osname-template.sh [TEMPLATE_ID] [STORAGE]

# Пример
./create-osname-template.sh 700 compute-storage
```

**Что делает:**
- Качает cloud image
- Ставит qemu-guest-agent
- Создает VM и конфигурирует
- Конвертирует в template

**Требования:**
- Proxmox VE 9.x
- Root доступ
- Интернет

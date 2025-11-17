# Proxmox Scripts

Утилиты для работы с Proxmox кластером.

## create-ubuntu-template.sh

Создает Ubuntu 22.04 cloud-init template для Proxmox.

**Использование:**
```bash
# На Proxmox ноде
./create-ubuntu-template.sh [TEMPLATE_ID] [STORAGE]

# Пример
./create-ubuntu-template.sh 700 compute-storage
```

**Что делает:**
- Качает Ubuntu 22.04 cloud image
- Ставит qemu-guest-agent
- Создает VM и конфигурирует
- Конвертирует в template

**Требования:**
- Proxmox VE 9.x
- Root доступ
- Интернет

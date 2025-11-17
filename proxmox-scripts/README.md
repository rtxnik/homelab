# Proxmox Scripts

Коллекция утилит для управления Proxmox VE кластером.

## Скрипты

### create-ubuntu-template.sh
Автоматическое создание Ubuntu cloud-init template для Proxmox.

**Использование:**
```bash
# На Proxmox ноде
./create-ubuntu-template.sh [TEMPLATE_ID] [STORAGE]

# Пример
./create-ubuntu-template.sh 700 compute-storage
```

**Что делает:**
- Скачивает Ubuntu 22.04 cloud image
- Устанавливает qemu-guest-agent
- Создает VM с правильной конфигурацией
- Конвертирует в template

## Требования

- Proxmox VE 8.x
- Root доступ к ноде
- Интернет для скачивания образов

## Установка

```bash
# На Proxmox ноде
git clone https://github.com/yourusername/proxmox-scripts.git
cd proxmox-scripts
chmod +x *.sh
```

## Связанные репозитории

- **homelab** - OpenTofu конфигурации для автоматизации инфраструктуры

## TODO

- [ ] Скрипт мониторинга здоровья кластера
- [ ] Автоматический бэкап VM
- [ ] Скрипт обновления всех нод
- [ ] Интеграция с мониторингом

## License

MIT

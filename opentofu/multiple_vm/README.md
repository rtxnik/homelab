# Multiple VM Provisioning

Развертывание нескольких виртуальных машин в Proxmox с индивидуальными параметрами для каждой VM.

## Отличия от single_vm

- ✅ Фиксированные VM ID для каждой машины
- ✅ Статические IP адреса вместо DHCP
- ✅ Индивидуальная конфигурация CPU/RAM для каждой VM
- ✅ Использование `for_each` вместо `count` для гибкого управления
- ✅ Группировка VM по нодам в outputs

## Что нужно

- OpenTofu >= 1.10.0
- Proxmox VE >= 9.x
- Cloud-init template (ID 700 по умолчанию)
- API token для Proxmox
- Настроенная сеть с gateway

## Структура конфигурации VM

Каждая VM описывается в `terraform.tfvars` как объект с параметрами:

```hcl
"vm-name" = {
  vm_id       = 121              # Фиксированный ID в Proxmox
  name        = "vm-01-small"    # Имя VM
  node        = "pve-compute-01" # Нода для размещения
  ip_address  = "10.0.10.21"     # Статический IP
  cpu_cores   = 2                # Количество ядер CPU
  memory_mb   = 4096             # RAM в мегабайтах
  description = "..."            # Описание
  tags        = ["small"]        # Дополнительные теги
}
```

## Пример конфигурации

В примере `terraform.tfvars.example` настроены 6 VM:

### pve-compute-01
- **vm-01-small** (ID 121): 10.0.10.21, 2 CPU, 4GB RAM
- **vm-01-large** (ID 131): 10.0.10.31, 4 CPU, 8GB RAM

### pve-compute-02
- **vm-02-small** (ID 122): 10.0.10.22, 2 CPU, 4GB RAM
- **vm-02-large** (ID 132): 10.0.10.32, 4 CPU, 8GB RAM

### pve-compute-03
- **vm-03-small** (ID 123): 10.0.10.23, 2 CPU, 4GB RAM
- **vm-03-large** (ID 133): 10.0.10.33, 4 CPU, 8GB RAM

## Настройка

```bash
# Скопировать пример переменных
cp terraform.tfvars.example terraform.tfvars

# Отредактировать под свою инфраструктуру
vim terraform.tfvars
```

### Обязательно настроить:

1. **Proxmox API:**
   ```hcl
   virtual_environment_endpoint  = "https://192.168.1.10:8006"
   virtual_environment_api_token = "root@pam!terraform=..."
   ```

2. **SSH ключ:**
   ```hcl
   ssh_public_key = "ssh-ed25519 AAAA..."
   ```

3. **Сеть:**
   ```hcl
   network_gateway = "10.0.10.1"      # Gateway вашей сети
   network_cidr    = 24                # Маска подсети
   dns_servers     = ["8.8.8.8", "1.1.1.1"]
   ```

4. **VM конфигурация:**
   - Отредактировать блок `vms` под свои нужды
   - Убедиться что IP адреса не конфликтуют
   - Проверить что VM ID свободны

## Использование

```bash
# Инициализация
tofu init

# Проверка плана
tofu plan

# Создание всех VM
tofu apply

# Создание конкретной VM
tofu apply -target='proxmox_virtual_environment_vm.vm["vm-01-small"]'

# Удаление конкретной VM
tofu destroy -target='proxmox_virtual_environment_vm.vm["vm-01-small"]'

# Удаление всех VM
tofu destroy
```

## Output информация

После `tofu apply` получим:

```hcl
# Детальная информация о каждой VM
vm_info = {
  "vm-01-small" = {
    cpu_cores  = 2
    id         = "pve-compute-01/qemu/121"
    ip_static  = "10.0.10.21"
    memory_mb  = 4096
    name       = "vm-01-small"
    node       = "pve-compute-01"
    status     = "running"
    vm_id      = 121
  }
  # ... остальные VM
}

# VM сгруппированные по нодам
vms_by_node = {
  "pve-compute-01" = [
    {
      cpu_cores  = 2
      ip_address = "10.0.10.21"
      memory_mb  = 4096
      name       = "vm-01-small"
      vm_id      = 121
    },
    # ...
  ]
  # ... остальные ноды
}

# SSH команды для подключения
ssh_commands = {
  "vm-01-small" = "ssh infra@10.0.10.21"
  "vm-01-large" = "ssh infra@10.0.10.31"
  # ...
}
```

## Управление конфигурацией

### Добавление новой VM

Добавить блок в `terraform.tfvars`:

```hcl
"vm-04-custom" = {
  vm_id       = 140
  name        = "vm-04-custom"
  node        = "pve-compute-01"
  ip_address  = "10.0.10.40"
  cpu_cores   = 8
  memory_mb   = 16384
  description = "Custom VM"
  tags        = ["custom", "high-performance"]
}
```

Затем `tofu apply`.

### Изменение параметров существующей VM

Изменить параметры в `terraform.tfvars` и выполнить `tofu apply`.

**⚠️ Внимание:** Изменение некоторых параметров требует пересоздания VM:
- `vm_id` - пересоздание
- `node` - пересоздание
- `ip_address` - можно изменить без пересоздания
- `cpu_cores`, `memory_mb` - можно изменить без пересоздания

### Удаление VM

Удалить блок из `terraform.tfvars` и выполнить `tofu apply`, или использовать `-target` для точечного удаления.

## Требования к сети

Для статических IP адресов необходимо:

1. **Настроенная подсеть:** IP адреса должны быть в правильной подсети
2. **Gateway:** Должен быть доступен указанный gateway
3. **Свободные IP:** Убедитесь что IP не используются другими устройствами
4. **VLAN (если используется):** Правильно настроенный bridge в Proxmox

## Проверка перед созданием VM

```bash
# Проверить свободные VM ID
for node in pve-compute-01 pve-compute-02 pve-compute-03; do
  echo "=== $node ==="
  ssh root@$node "qm list | grep -E '(121|131|122|132|123|133)'"
done

# Проверить доступность IP адресов
for ip in 10.0.10.{21,31,22,32,23,33}; do
  echo -n "Testing $ip: "
  ping -c 1 -W 1 $ip >/dev/null 2>&1 && echo "USED" || echo "FREE"
done

# Проверить доступность gateway
ping -c 3 10.0.10.1
```

## Типичные проблемы

### VM ID уже занят

```
Error: VM with ID 121 already exists
```

**Решение:** Выбрать другой ID или удалить существующую VM:
```bash
ssh root@pve-compute-01 "qm destroy 121"
```

### IP адрес уже используется

После создания VM нет связи - возможно IP конфликт.

**Решение:**
- Проверить `arp -a` на другом хосте в сети
- Использовать другой IP адрес

### VM не получает IP

Cloud-init не применяет конфигурацию.

**Решение:**
- Убедиться что template содержит `cloud-init` диск
- Проверить что в template установлен `cloud-init` пакет
- Проверить логи: `journalctl -u cloud-init`

### Gateway недоступен

VM создана но нет связи с внешним миром.

**Решение:**
- Проверить что gateway существует и доступен
- Проверить VLAN конфигурацию
- Проверить firewall правила в OPNsense

## Расширенное использование

### Создание VM с разными дисками

Изменить `vm_disk_size_gb` можно добавив в переменную VM, но потребуется модификация `main.tf`.

### Использование разных template

Можно создать несколько конфигураций с разными template для разных типов VM (Ubuntu, Debian, Rocky Linux).

### Интеграция с Ansible

После создания VM использовать output `ssh_commands` для генерации Ansible inventory:

```bash
tofu output -json ssh_commands | jq -r 'to_entries[] | "\(.key) ansible_host=\(.value | split("@")[1])"'
```

## Следующие шаги

После развертывания VM:

1. **Проверить подключение:** `ssh infra@10.0.10.21`
2. **Установить обновления:** `sudo apt update && sudo apt upgrade -y`
3. **Настроить мониторинг:** Prometheus node_exporter
4. **Добавить в Ansible inventory**
5. **Настроить backup**

## См. также

- [../single_vm/README.md](../single_vm/README.md) - Базовая конфигурация для одной VM
- [../../proxmox-scripts/README.md](../../proxmox-scripts/README.md) - Скрипты для Proxmox

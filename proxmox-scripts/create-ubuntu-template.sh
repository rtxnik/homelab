#!/bin/bash
set -e

# Параметры
TEMPLATE_ID=${1:-700}
STORAGE=${2:-compute-storage}
TEMPLATE_NAME="ubuntu-22.04-cloudinit-template"
IMAGE_FILE="jammy-server-cloudimg-amd64.img"
IMAGE_URL="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"

echo "============================================"
echo "Creating Ubuntu 22.04 Cloud-Init Template"
echo "============================================"
echo "Template ID: $TEMPLATE_ID"
echo "Storage: $STORAGE"
echo "============================================"

# Проверка, что скрипт запущен на Proxmox ноде
if ! command -v qm &> /dev/null; then
    echo "Error: This script must be run on a Proxmox VE node"
    exit 1
fi

# Проверка, что template с таким ID не существует
if qm status $TEMPLATE_ID &> /dev/null; then
    echo "Error: VM/Template with ID $TEMPLATE_ID already exists"
    echo "Please choose a different ID or remove existing VM/template"
    exit 1
fi

# Установка зависимостей
echo ""
echo "Installing dependencies..."
apt update && apt install -y libguestfs-tools wget

# Скачивание образа
if [ ! -f "$IMAGE_FILE" ]; then
    echo ""
    echo "Downloading Ubuntu cloud image..."
    wget --progress=bar:force --backups=1 $IMAGE_URL
else
    echo ""
    echo "Image already exists, using cached version: $IMAGE_FILE"
fi

# Установка qemu-guest-agent в образ
echo ""
echo "Installing qemu-guest-agent into image..."
virt-customize -a $IMAGE_FILE --install qemu-guest-agent

# Создание VM
echo ""
echo "Creating VM $TEMPLATE_ID..."
qm create $TEMPLATE_ID \
  --name "$TEMPLATE_NAME" \
  --cores 2 \
  --memory 2048 \
  --net0 virtio,bridge=vmbr0 \
  --scsihw virtio-scsi-pci

# Импорт диска
echo ""
echo "Importing disk..."
qm set $TEMPLATE_ID --virtio0 ${STORAGE}:0,import-from=$(pwd)/$IMAGE_FILE

# Настройка cloud-init
echo ""
echo "Configuring cloud-init..."
qm set $TEMPLATE_ID --ide2 ${STORAGE}:cloudinit
qm set $TEMPLATE_ID --boot order=virtio0
qm set $TEMPLATE_ID --serial0 socket --vga serial0

# Конвертация в template
echo ""
echo "Converting VM to template..."
qm template $TEMPLATE_ID

echo ""
echo "============================================"
echo "Template created successfully!"
echo "============================================"
echo "Template ID: $TEMPLATE_ID"
echo "Template Name: $TEMPLATE_NAME"
echo "Storage: $STORAGE"
echo ""
echo "You can now use this template with OpenTofu"
echo "============================================"

# Очистка
echo ""
read -p "Remove downloaded image file? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -f $IMAGE_FILE*
    echo "Image file removed"
fi

echo ""
echo "Done!"

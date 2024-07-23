#!/bin/bash

# Directorio y nombre del archivo de respaldo
BACKUP_FILE="$HOME/backup/backup.tar.gz"

# Crear directorio de respaldo si no existe
mkdir -p "$HOME/backup"

# Crear una copia de seguridad completa del sistema
sudo tar --exclude='/proc' --exclude='/tmp' --exclude='/sys' --exclude='/dev' --exclude='/run' --exclude='/mnt' --exclude='/media' --exclude='/lost+found' -czpf "$BACKUP_FILE" /

# Mensaje de confirmación
echo "Copia de seguridad creada en $BACKUP_FILE"

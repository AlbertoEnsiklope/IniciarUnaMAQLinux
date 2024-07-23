#!/bin/bash

# Archivo de respaldo que quieres restaurar
BACKUP_FILE="$HOME/backup/backup.tar.gz"

# Restaurar la copia de seguridad
sudo tar -xzpf "$BACKUP_FILE" -C /

# Mensaje de confirmación
echo "Sistema restaurado desde $BACKUP_FILE"

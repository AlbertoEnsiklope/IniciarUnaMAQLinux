#!/bin/bash

# Variables de configuración
BACKUP_DIR="$HOME/backup"
BACKUP_FILE="$BACKUP_DIR/backup.tar.gz"
RESTORE_SCRIPT="$BACKUP_DIR/restore_backup.sh"
LOG_FILE="$BACKUP_DIR/backup_log.txt"
TOTAL_SIZE_FILE="$BACKUP_DIR/total_size.txt"

# Función para instalar dependencias
install_dependencies() {
    echo "Verificando e instalando dependencias..."

    # Verificar si pv está instalado
    if ! command -v pv &> /dev/null; then
        echo "pv no está instalado. Instalando..."
        sudo apt-get update
        sudo apt-get install -y pv
    else
        echo "pv ya está instalado."
    fi
}

# Función para crear la copia de seguridad
create_backup() {
    # Crear directorio de respaldo si no existe
    mkdir -p "$BACKUP_DIR"

    # Eliminar el archivo de respaldo si ya existe
    if [ -f "$BACKUP_FILE" ]; then
        echo "El archivo de respaldo ya existe y será sobrescrito." | tee -a "$LOG_FILE"
        rm "$BACKUP_FILE"
    fi

    # Estimar el tamaño total del sistema de archivos para `pv`
    echo "Calculando el tamaño total del sistema de archivos..."
    sudo du -sb / | awk '{print $1}' > "$TOTAL_SIZE_FILE"

    # Crear una copia de seguridad completa del sistema
    echo "Iniciando la copia de seguridad..." | tee -a "$LOG_FILE"

    # Usar `pv` para mostrar la barra de progreso mientras se crea el respaldo
    sudo tar --exclude='/proc' --exclude='/tmp' --exclude='/sys' --exclude='/dev' --exclude='/run' --exclude='/mnt' --exclude='/media' --exclude='/lost+found' -czpf - / | pv -s $(cat "$TOTAL_SIZE_FILE") | sudo tee "$BACKUP_FILE" > /dev/null

    # Verificar si el archivo de respaldo se creó correctamente
    if [ -f "$BACKUP_FILE" ]; then
        echo "Copia de seguridad creada en $BACKUP_FILE" | tee -a "$LOG_FILE"
    else
        echo "Error al crear el archivo de respaldo." | tee -a "$LOG_FILE"
        exit 1
    fi

    # Limpiar archivo temporal
    rm "$TOTAL_SIZE_FILE"
}

# Función para crear el script de restauración
create_restore_script() {
    echo "Creando el script de restauración..." | tee -a "$LOG_FILE"

    cat << 'EOF' > "$RESTORE_SCRIPT"
#!/bin/bash

# Archivo de respaldo que quieres restaurar
BACKUP_FILE="$HOME/backup/backup.tar.gz"

# Restaurar la copia de seguridad
sudo tar -xzpf "$BACKUP_FILE" -C /

# Mensaje de confirmación
echo "Sistema restaurado desde $BACKUP_FILE"
EOF

    # Asignar permisos de ejecución al script de restauración
    chmod +x "$RESTORE_SCRIPT"

    # Mensaje de confirmación de creación del script de restauración
    echo "Script de restauración creado y configurado en $RESTORE_SCRIPT" | tee -a "$LOG_FILE"
}

# Ejecutar funciones
install_dependencies
create_backup
create_restore_script

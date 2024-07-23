#!/bin/bash

# Ruta del script
SCRIPT_PATH=$(realpath "$0")

# Función para verificar si un directorio es crítico
es_directorio_critico() {
    local DIR=$1
    local DIRECTORIOS_CRITICOS="/etc /bin /sbin /lib /lib64 /usr"

    for CRITICO in $DIRECTORIOS_CRITICOS; do
        if [[ $DIR == $CRITICO* ]]; then
            return 0
        fi
    done
    return 1
}

# Función para eliminar archivos y carpetas creados en la sesión actual
eliminar_archivos_y_carpetas() {
    local start_time=$1
    local dir=$2

    if es_directorio_critico "$dir"; then
        echo "El directorio $dir es crítico. No se eliminarán archivos en este directorio."
        return
    fi

    if [ ! -r "$dir" ]; then
        echo "No se tiene acceso al directorio: $dir"
        return
    fi

    echo "Buscando en el directorio: $dir"

    # Encuentra y elimina archivos creados en la sesión actual, excluyendo el archivo del script
    find "$dir" -type f -newermt "@$start_time" -print0 2>/dev/null | while IFS= read -r -d '' FILE; do
        if [ -r "$FILE" ]; then
            if [ "$FILE" != "$SCRIPT_PATH" ]; then
                echo "Eliminando archivo: $FILE"
                sudo rm -f "$FILE"
            else
                echo "No se eliminará el archivo del script: $FILE"
            fi
        else
            echo "No se tiene acceso al archivo: $FILE"
        fi
    done

    # Encuentra y elimina carpetas creadas en la sesión actual, excluyendo la carpeta del script
    find "$dir" -type d -newermt "@$start_time" -print0 2>/dev/null | while IFS= read -r -d '' DIR; do
        if [ -r "$DIR" ]; then
            if [ "$DIR" != "$(dirname "$SCRIPT_PATH")" ] && ! es_directorio_critico "$DIR"; then
                if [ "$(ls -A "$DIR" 2>/dev/null)" ]; then
                    echo "El directorio $DIR no está vacío. No se eliminará."
                else
                    echo "Eliminando carpeta: $DIR"
                    sudo rm -rf "$DIR"
                fi
            else
                echo "No se eliminará la carpeta del script o es un directorio crítico: $DIR"
            fi
        else
            echo "No se tiene acceso a la carpeta: $DIR"
        fi
    done
}

# Verifica la fecha de inicio de la sesión
SESSION_START=$(date -d "$(who -b | awk '{print $3, $4}')" +%s)

# Lista todos los paquetes instalados y sus fechas de instalación
INSTALLED_PACKAGES=$(dpkg-query -W -f='${Package} ${Status} ${Version}\n' | grep "install ok installed" | awk '{print $1}')

echo "Paquetes instalados en la sesión actual:"

for PACKAGE in $INSTALLED_PACKAGES; do
    INSTALL_DATE=$(grep "install $PACKAGE" /var/log/dpkg.log* | grep -E "install" | tail -n 1 | awk '{print $1, $2}' | sed 's/\[.*\]//g' | sed 's/:[0-9][0-9]$//g')
    INSTALL_TIMESTAMP=$(date -d "$INSTALL_DATE" +%s)
    if [ "$INSTALL_TIMESTAMP" -ge "$SESSION_START" ]; then
        echo "Eliminando paquete: $PACKAGE"
        sudo apt-get remove --purge -y $PACKAGE
    fi
done

# Limpia los paquetes no necesarios
sudo apt-get autoremove --purge -y

# Limpia archivos temporales y cachés
sudo apt-get autoclean
sudo apt-get clean

# Eliminar archivos y carpetas creados en la sesión actual en directorios accesibles
echo "Eliminando archivos y carpetas creados en la sesión actual:"

# Directorios comunes donde se puede tener acceso
DIRECTORIOS="/home /tmp /var/tmp /var/log"

for DIR in $DIRECTORIOS; do
    eliminar_archivos_y_carpetas "$SESSION_START" "$DIR"
done

echo "Proceso completado."

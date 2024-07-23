#!/bin/bash

# Función para eliminar archivos y carpetas creados en la sesión actual
eliminar_archivos_y_carpetas() {
    local start_time=$1
    local dir=$2

    if [ ! -r "$dir" ]; then
        echo "No se tiene acceso al directorio: $dir"
        return
    fi

    echo "Buscando en el directorio: $dir"

    # Encuentra y elimina archivos creados en la sesión actual
    find "$dir" -type f -newermt "@$start_time" -print0 2>/dev/null | while IFS= read -r -d '' FILE; do
        if [ -r "$FILE" ]; then
            echo "Eliminando archivo: $FILE"
            sudo rm -f "$FILE"
        else
            echo "No se tiene acceso al archivo: $FILE"
        fi
    done

    # Encuentra y elimina carpetas creadas en la sesión actual
    find "$dir" -type d -newermt "@$start_time" -print0 2>/dev/null | while IFS= read -r -d '' DIR; do
        if [ -r "$DIR" ]; then
            if [ "$(ls -A "$DIR" 2>/dev/null)" ]; then
                echo "El directorio $DIR no está vacío. No se eliminará."
            else
                echo "Eliminando carpeta: $DIR"
                sudo rm -rf "$DIR"
            fi
        else
            echo "No se tiene acceso a la carpeta: $DIR"
        fi
    done
}

# Verifica la fecha de inicio de la sesión
SESSION_START=$(date -d "$(who -b | awk '{print $3, $4}')" +%s)

# Lista todos los paquetes instalados y sus fechas de instalación
echo "Paquetes instalados en la sesión actual:"

# Extrae la lista de paquetes y sus fechas de instalación
while read -r PACKAGE INFO; do
    INSTALL_DATE=$(grep "install $PACKAGE" /var/log/dpkg.log* | grep -E "install" | tail -n 1 | awk '{print $1, $2}')
    if [ -n "$INSTALL_DATE" ]; then
        INSTALL_TIMESTAMP=$(date -d "$INSTALL_DATE" +%s)
        if [ "$INSTALL_TIMESTAMP" -ge "$SESSION_START" ]; then
            echo "Eliminando paquete: $PACKAGE"
            sudo apt-get remove --purge -y "$PACKAGE"
        fi
    fi
done < <(dpkg-query -W -f='${Package}\n' | xargs -I{} bash -c 'echo "{}"')

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

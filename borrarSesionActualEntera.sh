#!/bin/bash

# Este script elimina las aplicaciones instaladas en la sesión actual.

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

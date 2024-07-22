#!/bin/bash

# Archivo para registrar los errores
ERROR_LOG="$HOME/errorescomunes.txt"

# Función para descargar un archivo con reintento en caso de fallo
download_with_retry() {
    local url=$1
    local output=$2
    local max_retries=1
    local attempt=0

    while [[ $attempt -le $max_retries ]]; do
        echo "Intento $((attempt + 1)) de descarga de $url..."
        wget -O "$HOME/$output" "$url" 2>> "$ERROR_LOG"

        if [[ $? -eq 0 ]]; then
            echo "Descarga completada exitosamente."
            return 0
        else
            echo "Error en la descarga. Intentando nuevamente..." 2>> "$ERROR_LOG"
            attempt=$((attempt + 1))
        fi
    done

    echo "Fallo en la descarga después de $max_retries intentos." 2>> "$ERROR_LOG"
    return 1
}

# Nombre de usuario actual
CURRENT_USER=$(logname)

# Verificar si el usuario actual ya es un sudoer
if id -nG "$CURRENT_USER" | grep -qw "sudo"; then
    echo "El usuario '$CURRENT_USER' ya tiene permisos de sudo."
else
    echo "El usuario '$CURRENT_USER' no es un sudoer. Añadiéndolo al grupo 'sudo'..."
    sudo usermod -aG sudo "$CURRENT_USER" 2>> "$ERROR_LOG"
    echo "El usuario '$CURRENT_USER' ha sido añadido al grupo 'sudo' y ahora tiene permisos de administración."
fi

# Crear un nuevo grupo 'lectura'
echo "Creando el grupo 'lectura'..."
sudo groupadd lectura 2>> "$ERROR_LOG"

# Crear usuario 'franco' con contraseña 'buenastardes'
echo "Creando usuario 'franco'..."
sudo useradd -m -s /bin/bash franco 2>> "$ERROR_LOG"

echo "Estableciendo contraseña para 'franco'..."
echo 'franco:buenastardes' | sudo chpasswd 2>> "$ERROR_LOG"

# Añadir el usuario 'franco' al grupo 'lectura' (sin permisos de sudo)
echo "Añadiendo usuario 'franco' al grupo 'lectura'..."
sudo usermod -aG lectura franco 2>> "$ERROR_LOG"

# Descargar e instalar Chrome Remote Desktop
echo "Descargando Chrome Remote Desktop..."
download_with_retry "https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb" "chrome-remote-desktop_current_amd64.deb"

echo "Instalando Chrome Remote Desktop..."
expect << EOF 2>> "$ERROR_LOG"
spawn sudo apt install -y $HOME/chrome-remote-desktop_current_amd64.deb
expect "Enter your desired code:"
send "84\r"
expect "Enter your desired key:"
send "8\r"
expect eof
EOF

# Instalar entorno de escritorio XFCE y otras dependencias
echo "Instalando XFCE y dependencias..."
sudo DEBIAN_FRONTEND=noninteractive apt install --assume-yes xfce4 desktop-base dbus-x11 xscreensaver 2>> "$ERROR_LOG"

# Configurar Chrome Remote Desktop para usar XFCE
echo "Configurando Chrome Remote Desktop para usar XFCE..."
sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" > /etc/chrome-remote-desktop-session' 2>> "$ERROR_LOG"

# Descargar e instalar Firefox
echo "Descargando Firefox..."
download_with_retry "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=es-ES" "firefox.tar.bz2"

echo "Extrayendo Firefox..."
tar xjf "$HOME/firefox.tar.bz2" -C "$HOME" 2>> "$ERROR_LOG"

echo "Moviendo Firefox a /opt/firefox..."
sudo mv "$HOME/firefox" /opt/firefox 2>> "$ERROR_LOG"

echo "Creando enlace simbólico para Firefox..."
sudo ln -s /opt/firefox/firefox /usr/bin/firefox 2>> "$ERROR_LOG"

# Instalar unzip si no está instalado
echo "Instalando unzip..."
sudo apt install -y unzip 2>> "$ERROR_LOG"

# Establecer Firefox como navegador predeterminado
echo "Estableciendo Firefox como navegador predeterminado..."
sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/firefox 200 2>> "$ERROR_LOG"
sudo update-alternatives --install /usr/bin/gnome-www-browser gnome-www-browser /usr/bin/firefox 200 2>> "$ERROR_LOG"

# Crear script de desinstalación en el directorio home
UNINSTALL_SCRIPT="$HOME/diablooo.sh"
INSTALL_SCRIPT=$(realpath $0)

cat << EOF > "$UNINSTALL_SCRIPT"
#!/bin/bash

# Eliminar archivos descargados
echo "Eliminando archivo de instalación de Chrome Remote Desktop..."
rm -f "$HOME/chrome-remote-desktop_current_amd64.deb" 2>> "$ERROR_LOG"

echo "Eliminando archivo tar de Firefox..."
rm -f "$HOME/firefox.tar.bz2" 2>> "$ERROR_LOG"

# Ruta del script de instalación
INSTALL_SCRIPT="$INSTALL_SCRIPT"
# Ruta del script de desinstalación
UNINSTALL_SCRIPT="\$0"

# Eliminar el script de instalación
if [ -f "\$INSTALL_SCRIPT" ]; then
    rm -f "\$INSTALL_SCRIPT"
    echo "Script de instalación eliminado."
else
    echo "Script de instalación no encontrado."
fi

# Eliminar el script de desinstalación
if [ -f "\$UNINSTALL_SCRIPT" ]; then
    rm -f "\$UNINSTALL_SCRIPT"
    echo "Script de desinstalación eliminado."
else
    echo "Script de desinstalación no encontrado."
fi

# Eliminar Chrome Remote Desktop
sudo apt-get remove --purge -y chrome-remote-desktop 2>> "$ERROR_LOG"
sudo apt-get autoremove -y 2>> "$ERROR_LOG"
echo "Chrome Remote Desktop eliminado."

# Eliminar Firefox
sudo rm -rf /opt/firefox 2>> "$ERROR_LOG"
sudo rm -f /usr/bin/firefox 2>> "$ERROR_LOG"
echo "Firefox eliminado."

# Eliminar XFCE y otras dependencias
# Comentar o eliminar la línea siguiente para no eliminar XFCE
# sudo apt-get remove --purge -y xfce4 desktop-base dbus-x11 xscreensaver 2>> "$ERROR_LOG"

# Limpiar caché y archivos residuales
sudo apt-get clean 2>> "$ERROR_LOG"
echo "Caché y archivos residuales limpiados."

# Limpiar la consola
clear

# Mensaje final y esperar a que se presione una tecla
echo "Desinstalación completada."
echo "Presiona cualquier tecla para continuar..."
read -n 1 -s
EOF

# Hacer el script de desinstalación ejecutable
echo "Haciendo el script de desinstalación ejecutable..."
chmod +x "$UNINSTALL_SCRIPT" 2>> "$ERROR_LOG"

# Crear accesos directos en el escritorio
DESKTOP_DIR="$HOME/Desktop"

# Crear acceso directo al script de instalación
cat << EOF > "$DESKTOP_DIR/Instalador.desktop"
[Desktop Entry]
Name=Instalador
Comment=Ejecutar el script de instalación
Exec=/bin/bash $INSTALL_SCRIPT
Icon=utilities-terminal
Terminal=true
Type=Application
Categories=Utility;
EOF

# Crear acceso directo al script de desinstalación
cat << EOF > "$DESKTOP_DIR/Desinstalador.desktop"
[Desktop Entry]
Name=Desinstalador
Comment=Ejecutar el script de desinstalación
Exec=/bin/bash $UNINSTALL_SCRIPT
Icon=utilities-terminal
Terminal=true
Type=Application
Categories=Utility;
EOF

# Crear acceso directo a Firefox
cat << EOF > "$DESKTOP_DIR/Firefox.desktop"
[Desktop Entry]
Name=Firefox
Comment=Lanzar navegador Firefox
Exec=/usr/bin/firefox
Icon=firefox
Terminal=false
Type=Application
Categories=Network;WebBrowser;
EOF

# Crear acceso directo a la terminal con permisos de superadministrador
cat << EOF > "$DESKTOP_DIR/Terminal_Superadmin.desktop"
[Desktop Entry]
Name=Terminal Superadmin
Comment=Lanzar terminal con sudo
Exec=pkexec gnome-terminal
Icon=utilities-terminal
Terminal=false
Type=Application
Categories=Utility;TerminalEmulator;
EOF

# Crear acceso directo a la terminal sin permisos de administrador
cat << EOF > "$DESKTOP_DIR/Terminal.desktop"
[Desktop Entry]
Name=Terminal
Comment=Lanzar terminal
Exec=gnome-terminal
Icon=utilities-terminal
Terminal=false
Type=Application
Categories=Utility;TerminalEmulator;
EOF

# Crear acceso directo a la URL usando Firefox
cat << EOF > "$DESKTOP_DIR/Codeshare.desktop"
[Desktop Entry]
Name=Codeshare
Comment=Abrir Codeshare.io en Firefox
Exec=/usr/bin/firefox https://codeshare.io/EEEEEqQqwwwExEEEEE
Icon=firefox
Terminal=false
Type=Application
Categories=Network;WebBrowser;
EOF

# Hacer los accesos directos ejecutables
echo "Haciendo los accesos directos ejecutables..."
chmod +x "$DESKTOP_DIR/Instalador.desktop" 2>> "$ERROR_LOG"
chmod +x "$DESKTOP_DIR/Desinstalador.desktop" 2>> "$ERROR_LOG"
chmod +x "$DESKTOP_DIR/Firefox.desktop" 2>> "$ERROR_LOG"
chmod +x "$DESKTOP_DIR/Terminal_Superadmin.desktop" 2>> "$ERROR_LOG"
chmod +x "$DESKTOP_DIR/Terminal.desktop" 2>> "$ERROR_LOG"
chmod +x "$DESKTOP_DIR/Codeshare.desktop" 2>> "$ERROR_LOG"

# Nombre del archivo del script de temporizador
TIMER_SCRIPT="$HOME/erTiemponado.sh"
DESKTOP_FILE="$HOME/Desktop/erTiemponado.desktop"

# Verificar si el script de temporizador ya existe
if [ ! -f "$TIMER_SCRIPT" ]; then
    echo "Creando el script de temporizador ($TIMER_SCRIPT)..."
    
    # Crear el script de temporizador
    cat << EOF > "$TIMER_SCRIPT"
#!/bin/bash

# Archivo para guardar el número de horas
COUNT_FILE="\$HOME/hours_counter.txt"

# Inicializar el contador si el archivo no existe
if [ ! -f "\$COUNT_FILE" ]; then
    echo 0 > "\$COUNT_FILE"
fi

# Leer el contador actual
COUNTER=\$(cat "\$COUNT_FILE")

# Función para mostrar una notificación
notify() {
    local message="\$1"
    # Comando para mostrar notificaciones en el escritorio
    if command -v notify-send &> /dev/null; then
        notify-send "Horas Contador" "\$message"
    else
        echo "\$message"
    fi
}

# Función para incrementar el contador y mostrar en pantalla
increment_counter() {
    COUNTER=\$((COUNTER + 1))
    echo \$COUNTER > "\$COUNT_FILE"
    echo "Horas transcurridas: \$COUNTER"  # Mostrar en pantalla
}

# Bucle para contar las horas
while [ \$COUNTER -lt 100 ]; do
    sleep 1h  # Esperar 1 hora
    increment_counter

    if [ \$COUNTER -eq 50 ]; then
        notify "El contador ha llegado a 50 horas."
    elif [ \$COUNTER -gt 50 ] && [ \$COUNTER -lt 100 ]; then
        echo "Horas transcurridas: \$COUNTER"  # Mostrar en pantalla
    fi
done

# Notificación cuando se llega a 100 horas
notify "El contador ha llegado a 100 horas."
echo "Contador alcanzó 100 horas. Script finalizado."
EOF

    # Hacer el script ejecutable
    chmod +x "$TIMER_SCRIPT" 2>> "$ERROR_LOG"

    echo "El script de temporizador ha sido creado y configurado para no ejecutarse automáticamente."
fi

# Crear acceso directo en el escritorio para el script de temporizador
if [ ! -f "$DESKTOP_FILE" ]; then
    echo "Creando acceso directo en el escritorio ($DESKTOP_FILE)..."
    
    cat << EOF > "$DESKTOP_FILE"
[Desktop Entry]
Name=Temporizador
Comment=Ejecutar el script de temporizador
Exec=/bin/bash $TIMER_SCRIPT
Icon=utilities-terminal
Terminal=true
Type=Application
Categories=Utility;
EOF

    # Hacer el acceso directo ejecutable
    chmod +x "$DESKTOP_FILE" 2>> "$ERROR_LOG"
fi

echo "Script completado. El script de temporizador está listo para ser ejecutado desde el acceso directo en el escritorio."

# Mostrar mensaje de acceso a Chrome Remote Desktop
echo "ACCEDER A Chrome Remote Desktop Access: https://remotedesktop.google.com/headless"
echo "RECORDAR PIN: 123456"

# Descargar e instalar Chrome Remote Desktop
wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
sudo apt install -y ./chrome-remote-desktop_current_amd64.deb

# Instalar entorno de escritorio XFCE y otras dependencias
sudo DEBIAN_FRONTEND=noninteractive apt install -y xfce4 desktop-base dbus-x11 xscreensaver

# Configurar Chrome Remote Desktop para usar XFCE
echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" | sudo tee /etc/chrome-remote-desktop-session

# Descargar e instalar Firefox
sudo mv firefox /opt/firefox
sudo ln -s /opt/firefox/firefox /usr/bin/firefox

# Instalar unzip si no está instalado
sudo apt install -y unzip

# Establecer Firefox como navegador predeterminado
sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/firefox 200
sudo update-alternatives --install /usr/bin/gnome-www-browser gnome-www-browser /usr/bin/firefox 200
rm -f firefox.tar.bz2

# Mensaje final y esperar a que se presione una tecla
echo "Script completado."
echo "Presiona cualquier tecla para continuar..."
read -n 1 -s

# Limpiar la consola
clear
echo "ACCEDER A Chrome Remote Desktop Access: https://remotedesktop.google.com/headless"

# Contar el número de errores registrados
ERROR_COUNT=$(wc -l < "$ERROR_LOG")
echo "Número total de errores registrados: $ERROR_COUNT"

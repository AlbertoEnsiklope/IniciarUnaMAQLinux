#!/bin/bash

# Función para descargar un archivo con reintento en caso de fallo
download_with_retry() {
    local url=$1
    local output=$2
    local max_retries=1
    local attempt=0

    while [[ $attempt -le $max_retries ]]; do
        echo "Intento $((attempt + 1)) de descarga de $url..."
        wget -O "$output" "$url"

        if [[ $? -eq 0 ]]; then
            echo "Descarga completada exitosamente."
            return 0
        else
            echo "Error en la descarga. Intentando nuevamente..."
            attempt=$((attempt + 1))
        fi
    done

    echo "Fallo en la descarga después de $max_retries intentos."
    return 1
}

# Nombre de usuario actual
CURRENT_USER=$(logname)

# Verificar si el usuario actual ya es un sudoer
if id -nG "$CURRENT_USER" | grep -qw "sudo"; then
    echo "El usuario '$CURRENT_USER' ya tiene permisos de sudo."
else
    echo "El usuario '$CURRENT_USER' no es un sudoer. Añadiéndolo al grupo 'sudo'..."
    usermod -aG sudo "$CURRENT_USER"
    echo "El usuario '$CURRENT_USER' ha sido añadido al grupo 'sudo' y ahora tiene permisos de administración."
fi

# Crear un nuevo grupo 'lectura'
echo "Creando el grupo 'lectura'..."
groupadd lectura

# Crear usuario 'franco' con contraseña 'buenastardes'
echo "Creando usuario 'franco'..."
useradd -m -s /bin/bash franco

echo "Estableciendo contraseña para 'franco'..."
echo 'franco:buenastardes' | chpasswd

# Añadir el usuario 'franco' al grupo 'lectura' (sin permisos de sudo)
echo "Añadiendo usuario 'franco' al grupo 'lectura'..."
usermod -aG lectura franco

# Descargar e instalar Chrome Remote Desktop
echo "Descargando Chrome Remote Desktop..."
download_with_retry "https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb" "chrome-remote-desktop_current_amd64.deb"

echo "Instalando Chrome Remote Desktop..."
expect << EOF
spawn apt install -y ./chrome-remote-desktop_current_amd64.deb
expect "Enter your desired code:"
send "84\r"
expect "Enter your desired key:"
send "8\r"
expect eof
EOF

# Instalar entorno de escritorio XFCE y otras dependencias
echo "Instalando XFCE y dependencias..."
sudo DEBIAN_FRONTEND=noninteractive apt install --assume-yes xfce4 desktop-base dbus-x11 xscreensaver

# Configurar Chrome Remote Desktop para usar XFCE
echo "Configurando Chrome Remote Desktop para usar XFCE..."
sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" > /etc/chrome-remote-desktop-session'

# Descargar e instalar Firefox
echo "Descargando Firefox..."
download_with_retry "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=es-ES" "firefox.tar.bz2"

echo "Extrayendo Firefox..."
tar xjf firefox.tar.bz2

echo "Moviendo Firefox a /opt/firefox..."
mv firefox /opt/firefox

echo "Creando enlace simbólico para Firefox..."
ln -s /opt/firefox/firefox /usr/bin/firefox

# Instalar unzip si no está instalado
echo "Instalando unzip..."
apt install -y unzip

# Establecer Firefox como navegador predeterminado
echo "Estableciendo Firefox como navegador predeterminado..."
update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/firefox 200
update-alternatives --install /usr/bin/gnome-www-browser gnome-www-browser /usr/bin/firefox 200

# Crear script de desinstalación en el directorio home
HOME_DIR=$(eval echo ~$CURRENT_USER)
UNINSTALL_SCRIPT="$HOME_DIR/diablooo.sh"
INSTALL_SCRIPT=$(realpath $0)

cat << EOF > "$UNINSTALL_SCRIPT"
#!/bin/bash

# Eliminar archivos descargados
echo "Eliminando archivo de instalación de Chrome Remote Desktop..."
rm -f chrome-remote-desktop_current_amd64.deb

echo "Eliminando archivo tar de Firefox..."
rm -f firefox.tar.bz2

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
apt-get remove --purge -y chrome-remote-desktop
apt-get autoremove -y
echo "Chrome Remote Desktop eliminado."

# Eliminar Firefox
rm -rf /opt/firefox
rm -f /usr/bin/firefox
echo "Firefox eliminado."

# Eliminar XFCE y otras dependencias
# Comentar o eliminar la línea siguiente para no eliminar XFCE
# apt-get remove --purge -y xfce4 desktop-base dbus-x11 xscreensaver

# Limpiar caché y archivos residuales
apt-get clean
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
chmod +x "$UNINSTALL_SCRIPT"

# Crear accesos directos en el escritorio
DESKTOP_DIR=$(eval echo ~$CURRENT_USER/Desktop)

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
chmod +x "$DESKTOP_DIR/Instalador.desktop"
chmod +x "$DESKTOP_DIR/Desinstalador.desktop"
chmod +x "$DESKTOP_DIR/Firefox.desktop"
chmod +x "$DESKTOP_DIR/Terminal_Superadmin.desktop"
chmod +x "$DESKTOP_DIR/Terminal.desktop"
chmod +x "$DESKTOP_DIR/Codeshare.desktop"

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
    chmod +x "$TIMER_SCRIPT"

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
    chmod +x "$DESKTOP_FILE"
fi

echo "Script completado. El script de temporizador está listo para ser ejecutado desde el acceso directo en el escritorio."

# Mostrar mensaje de acceso a Chrome Remote Desktop
echo "ACCEDER A Chrome Remote Desktop Access: https://remotedesktop.google.com/headless"
echo "RECORDAR PIN: 123456"

# Mensaje final y esperar a que se presione una tecla
echo "Script completado."
echo "Presiona cualquier tecla para continuar..."
read -n 1 -s

# Limpiar la consola
clear
echo "ACCEDER A Chrome Remote Desktop Access: https://remotedesktop.google.com/headless"

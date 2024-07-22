#!/bin/bash

# Funcion para ejecutar un comando y verificar su exito
execute_command() {
    local command="$1"
    local description="$2"
    
    echo "Ejecutando: $description"
    if eval "$command"; then
        echo "$description: OK"
    else
        echo "$description: FALLO"
        return 1
    fi
    return 0
}

# Funcion para volver a intentar la ejecucion si fallo
retry_command() {
    local command="$1"
    local description="$2"
    
    execute_command "$command" "$description"
    if [ $? -ne 0 ]; then
        echo "Reintentando: $description"
        execute_command "$command" "$description"
    fi
}

# Actualizar el sistema y asegurarse de que 'expect' este instalado
retry_command "sudo apt-get update" "Actualizar el sistema"
retry_command "sudo apt-get install -y expect wget" "Instalar expect y wget"

# Crear usuario 'franco' con contrasena 'vivaspain'
retry_command "sudo useradd -m -s /bin/bash franco" "Crear usuario 'franco'"
retry_command "echo 'franco:vivaspain' | sudo chpasswd" "Establecer contrasena para 'franco'"

# Agregar el usuario 'franco' al grupo 'sudo'
retry_command "sudo usermod -aG sudo franco" "Agregar usuario 'franco' al grupo 'sudo'"

# Descargar e instalar Chrome Remote Desktop
retry_command "wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb" "Descargar Chrome Remote Desktop"
retry_command "sudo apt install -y ./chrome-remote-desktop_current_amd64.deb" "Instalar Chrome Remote Desktop"

# Instalar entorno de escritorio XFCE y otras dependencias
retry_command "sudo DEBIAN_FRONTEND=noninteractive apt install -y xfce4 desktop-base dbus-x11 xscreensaver" "Instalar XFCE y dependencias"

# Configurar Chrome Remote Desktop para usar XFCE
retry_command "echo 'exec /etc/X11/Xsession /usr/bin/xfce4-session' | sudo tee /etc/chrome-remote-desktop-session" "Configurar Chrome Remote Desktop"

# Descargar e instalar Firefox
retry_command "wget -O firefox.tar.bz2 'https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=es-ES'" "Descargar Firefox"
retry_command "tar xjf firefox.tar.bz2" "Extraer Firefox"
retry_command "sudo mv firefox /opt/firefox" "Mover Firefox a /opt/firefox"
retry_command "sudo ln -s /opt/firefox/firefox /usr/bin/firefox" "Crear enlace simbolico para Firefox"

# Instalar unzip si no esta instalado
retry_command "sudo apt install -y unzip" "Instalar unzip"

# Establecer Firefox como navegador predeterminado
retry_command "sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/firefox 200" "Establecer Firefox como navegador predeterminado"
retry_command "sudo update-alternatives --install /usr/bin/gnome-www-browser gnome-www-browser /usr/bin/firefox 200" "Establecer Firefox como navegador predeterminado (gnome-www-browser)"

# Eliminar archivos descargados
retry_command "rm -f chrome-remote-desktop_current_amd64.deb" "Eliminar archivo de instalacion de Chrome Remote Desktop"
retry_command "rm -f firefox.tar.bz2" "Eliminar archivo tar de Firefox"

# Crear script de desinstalacion en el directorio home
HOME_DIR=$(eval echo ~$USER)
UNINSTALL_SCRIPT="$HOME_DIR/diablooo.sh"
INSTALL_SCRIPT=$(realpath $0)

cat << EOF > "$UNINSTALL_SCRIPT"
#!/bin/bash

# Ruta del script de instalacion
INSTALL_SCRIPT="$INSTALL_SCRIPT"
# Ruta del script de desinstalacion
UNINSTALL_SCRIPT="\$0"

# Eliminar el script de instalacion
if [ -f "\$INSTALL_SCRIPT" ]; then
    rm -f "\$INSTALL_SCRIPT"
    echo "Script de instalacion eliminado."
else
    echo "Script de instalacion no encontrado."
fi

# Eliminar el script de desinstalacion
if [ -f "\$UNINSTALL_SCRIPT" ]; then
    rm -f "\$UNINSTALL_SCRIPT"
    echo "Script de desinstalacion eliminado."
else
    echo "Script de desinstalacion no encontrado."
fi

# Eliminar Chrome Remote Desktop
sudo apt-get remove --purge -y chrome-remote-desktop
sudo apt-get autoremove -y
echo "Chrome Remote Desktop eliminado."

# Eliminar Firefox
sudo rm -rf /opt/firefox
sudo rm -f /usr/bin/firefox
echo "Firefox eliminado."

# Eliminar XFCE y otras dependencias
# Comentar o eliminar la linea siguiente para no eliminar XFCE
# sudo apt-get remove --purge -y xfce4 desktop-base dbus-x11 xscreensaver

# Limpiar cache y archivos residuales
sudo apt-get clean
echo "Cache y archivos residuales limpiados."

# Limpiar la consola
clear

# Mensaje final y esperar a que se presione una tecla
echo "Desinstalacion completada."
echo "Presiona cualquier tecla para continuar..."
read -n 1 -s
EOF

# Hacer el script de desinstalacion ejecutable
retry_command "chmod +x '$UNINSTALL_SCRIPT'" "Hacer el script de desinstalacion ejecutable"

# Crear accesos directos en el escritorio
DESKTOP_DIR=$(eval echo ~$USER/Desktop)

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
Exec=gksudo gnome-terminal
Icon=utilities-terminal
Terminal=false
Type=Application
Categories=Utility;TerminalEmulator;
EOF

# Hacer los accesos directos ejecutables
retry_command "chmod +x '$DESKTOP_DIR/Firefox.desktop'" "Hacer el acceso directo a Firefox ejecutable"
retry_command "chmod +x '$DESKTOP_DIR/Terminal_Superadmin.desktop'" "Hacer el acceso directo a Terminal Superadmin ejecutable"

# Mostrar mensaje de acceso a Chrome Remote Desktop
echo "ACCEDER A Chrome Remote Desktop Access: https://remotedesktop.google.com"
echo "RECORDAR PIN: 123456"

# Mensaje final y esperar a que se presione una tecla
echo "Script completado."
echo "Presiona cualquier tecla para continuar..."
read -n 1 -s

# Limpiar la consola
clear

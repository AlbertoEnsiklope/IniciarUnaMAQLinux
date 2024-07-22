#!/bin/bash

# Actualizar el sistema y asegurarse de que 'expect' esté instalado
sudo apt-get update
sudo apt-get install -y expect wget

# Crear usuario 'franco' con contraseña 'vivaspain'
sudo useradd -m -s /bin/bash franco
echo "franco:vivaspain" | sudo chpasswd

# Agregar el usuario 'franco' al grupo 'sudo'
sudo usermod -aG sudo franco

# Descargar e instalar Chrome Remote Desktop
wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
sudo apt install -y ./chrome-remote-desktop_current_amd64.deb

# Instalar entorno de escritorio XFCE y otras dependencias
sudo DEBIAN_FRONTEND=noninteractive apt install -y xfce4 desktop-base dbus-x11 xscreensaver

# Configurar Chrome Remote Desktop para usar XFCE
echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" | sudo tee /etc/chrome-remote-desktop-session

# Descargar e instalar Firefox
wget -O firefox.tar.bz2 "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=es-ES"
tar xjf firefox.tar.bz2
sudo mv firefox /opt/firefox
sudo ln -s /opt/firefox/firefox /usr/bin/firefox

# Instalar unzip si no está instalado
sudo apt install -y unzip

# Establecer Firefox como navegador predeterminado
sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/firefox 200
sudo update-alternatives --install /usr/bin/gnome-www-browser gnome-www-browser /usr/bin/firefox 200


# Eliminar archivos descargados
rm -f chrome-remote-desktop_current_amd64.deb
rm -f firefox.tar.bz2

# Crear script de desinstalación en el directorio home
HOME_DIR=$(eval echo ~$USER)
UNINSTALL_SCRIPT="$HOME_DIR/diablooo.sh"
INSTALL_SCRIPT=$(realpath $0)

cat << EOF > "$UNINSTALL_SCRIPT"
#!/bin/bash

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
sudo apt-get remove --purge -y chrome-remote-desktop
sudo apt-get autoremove -y
echo "Chrome Remote Desktop eliminado."

# Eliminar Firefox
sudo rm -rf /opt/firefox
sudo rm -f /usr/bin/firefox
echo "Firefox eliminado."

# Eliminar XFCE y otras dependencias
# Comentar o eliminar la línea siguiente para no eliminar XFCE
# sudo apt-get remove --purge -y xfce4 desktop-base dbus-x11 xscreensaver

# Limpiar caché y archivos residuales
sudo apt-get clean
echo "Caché y archivos residuales limpiados."

# Limpiar la consola
clear

# Mensaje final y esperar a que se presione una tecla
echo "Desinstalación completada."
echo "Presiona cualquier tecla para continuar..."
read -n 1 -s
EOF

# Hacer el script de desinstalación ejecutable
chmod +x "$UNINSTALL_SCRIPT"

# Crear accesos directos en el escritorio

# Directorio del escritorio del usuario
DESKTOP_DIR=$(eval echo ~$USER/Desktop)

# Crear acceso directo a Firefox
cat << EOF > "$DESKTOP_DIR/Firefox.desktop"
[Desktop Entry]
Name=Firefox
Comment=Launch Firefox Browser
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
Comment=Launch Terminal with sudo
Exec=gksudo gnome-terminal
Icon=utilities-terminal
Terminal=false
Type=Application
Categories=Utility;TerminalEmulator;
EOF

# Hacer los accesos directos ejecutables
chmod +x "$DESKTOP_DIR/Firefox.desktop"
chmod +x "$DESKTOP_DIR/Terminal_Superadmin.desktop"

# Mostrar mensaje de acceso a Chrome Remote Desktop
echo "ACCEDER A Chrome Remote Desktop Access: https://remotedesktop.google.com"
echo "RECORDAR PIN: 123456"

# Mensaje final y esperar a que se presione una tecla
echo "Script completado."
echo "Presiona cualquier tecla para continuar..."
read -n 1 -s

# Limpiar la consola
clear

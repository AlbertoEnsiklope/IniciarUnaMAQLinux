#!/bin/bash

# Actualizar los paquetes del sistema
sudo apt update

# Instalar dependencias necesarias
sudo apt install -y wget tar

# Descargar la versión más reciente del navegador Tor
TOR_VERSION=$(curl -s https://www.torproject.org/download/ | grep -oP 'tor-browser-linux64-\K[0-9.]+(?=_ALL.tar.xz)' | head -1)
wget https://www.torproject.org/dist/torbrowser/$TOR_VERSION/tor-browser-linux64-$TOR_VERSION_ALL.tar.xz

# Extraer el archivo descargado
tar -xvf tor-browser-linux64-$TOR_VERSION_ALL.tar.xz

# Mover el navegador Tor a /opt
sudo mv tor-browser_en-US /opt/tor-browser

# Crear un acceso directo en el escritorio
mkdir -p ~/Escritorio
cat <<EOF > ~/Escritorio/tor-browser.desktop
[Desktop Entry]
Name=Tor Browser
Comment=Navegador Tor
Exec=/opt/tor-browser/start-tor-browser.desktop
Icon=/opt/tor-browser/browser/chrome/icons/default/default128.png
Terminal=false
Type=Application
EOF

# Dar permisos de ejecución al acceso directo
chmod +x ~/Escritorio/tor-browser.desktop

# Iniciar el navegador Tor
/opt/tor-browser/start-tor-browser.desktop &

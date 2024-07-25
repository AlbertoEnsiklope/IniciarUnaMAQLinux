#!/bin/bash

# Actualizar la lista de paquetes
sudo apt-get update

# Instalar jq para procesar JSON
sudo apt-get install -y jq

# Descargar la última versión de uBlock Origin
UBLOCK_URL=$(curl -s https://addons.mozilla.org/api/v4/addons/addon/ublock-origin/ | jq -r '.current_version.files[0].url')
wget -O ublock_origin.xpi $UBLOCK_URL

# Crear el directorio de extensiones si no existe
mkdir -p ~/.mozilla/extensions

# Mover la extensión descargada al directorio de extensiones
mv ublock_origin.xpi ~/.mozilla/extensions/

# Configurar Firefox para instalar la extensión
echo '{
  "policies": {
    "ExtensionSettings": {
      "uBlock0@raymondhill.net": {
        "installation_mode": "force_installed",
        "install_url": "file://'$HOME'/.mozilla/extensions/ublock_origin.xpi"
      }
    }
  }
}' > policies.json

# Mover el archivo de políticas a la ubicación correcta
sudo mkdir -p /etc/firefox/policies
sudo mv policies.json /etc/firefox/policies/

# Crear un acceso directo para Firefox
echo '[Desktop Entry]
Name=Firefox
Comment=Web Browser
Exec=firefox
Icon=firefox
Terminal=false
Type=Application
Categories=Network;WebBrowser;' > ~/Desktop/firefox.desktop

# Hacer el acceso directo ejecutable
chmod +x ~/Desktop/firefox.desktop

pulseaudio --kill
pulseaudio --start

echo "uBlock Origin ha sido instalado y configurado correctamente en Firefox."
echo "Se ha creado un acceso directo para Firefox en el escritorio."

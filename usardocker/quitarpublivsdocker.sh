#!/bin/bash

# Instalar jq y curl para procesar JSON
sudo apt-get install -y jq curl

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

# Crear el directorio Desktop si no existe
mkdir -p ~/Desktop

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

# Iniciar Firefox para crear el perfil
firefox &

# Esperar unos segundos para que Firefox cree el perfil
sleep 10

# Cerrar Firefox
pkill firefox

# Reiniciar PulseAudio
pulseaudio --kill
pulseaudio --start

# Configurar el user agent en Firefox
PROFILE_DIR=$(ls ~/.mozilla/firefox/ | grep '.default-release')
USER_AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36"

if [ -z "$PROFILE_DIR" ]; then
    echo "Profile directory not found!"
    exit 1
fi

echo "user_pref(\"general.useragent.override\", \"$USER_AGENT\");" >> ~/.mozilla/firefox/$PROFILE_DIR/user.js

echo "User agent set to: $USER_AGENT"

echo "uBlock Origin ha sido instalado y configurado correctamente en Firefox."
echo "Se ha creado un acceso directo para Firefox en el escritorio."

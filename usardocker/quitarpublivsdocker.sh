#!/bin/bash

sudo apt-get remove --purge -y firefox
rm -rf ~/.mozilla
sudo rm -rf /etc/firefox


sudo apt-get update
sudo apt-get install -y firefox

sudo apt-get install -y jq curl


download_extension() {
    local addon_name=$1
    local addon_url=$(curl -s "https://addons.mozilla.org/api/v4/addons/addon/$addon_name/" | jq -r '.current_version.files[0].url')
    wget -O "$addon_name.xpi" "$addon_url"
    if [ $? -ne 0 ]; then
        echo "Error al descargar $addon_name"
        exit 1
    fi
}


download_extension "ublock-origin"


mkdir -p ~/.mozilla/extensions


mv ublock-origin.xpi ~/.mozilla/extensions/

echo '{
  "policies": {
    "ExtensionSettings": {
      "uBlock0@raymondhill.net": {
        "installation_mode": "force_installed",
        "install_url": "file://'$HOME'/.mozilla/extensions/ublock-origin.xpi"
      }
    }
  }
}' > policies.json


sudo mkdir -p /etc/firefox/policies
sudo mv policies.json /etc/firefox/policies/


mkdir -p ~/Desktop


echo '[Desktop Entry]
Name=Firefox
Comment=Web Browser
Exec=firefox
Icon=firefox
Terminal=false
Type=Application
Categories=Network;WebBrowser;' > ~/Desktop/firefox.desktop


echo '[Desktop Entry]
Name=Gedit
Comment=Text Editor
Exec=gedit
Icon=gedit
Terminal=false
Type=Application
Categories=Utility;TextEditor;' > ~/Desktop/gedit.desktop


chmod +x ~/Desktop/firefox.desktop
chmod +x ~/Desktop/gedit.desktop


firefox &


sleep 10


pkill firefox


pulseaudio --kill
pulseaudio --start

PROFILE_DIR=$(ls ~/.mozilla/firefox/ | grep '.default-release')
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0"

if [ -z "$PROFILE_DIR" ]; then
    echo "Profile directory not found!"
    exit 1
fi

echo 'user_pref("general.useragent.override", "'$USER_AGENT'");' >> ~/.mozilla/firefox/$PROFILE_DIR/user.js
echo 'user_pref("browser.startup.homepage", "https://www.google.com");' >> ~/.mozilla/firefox/$PROFILE_DIR/user.js
echo 'user_pref("browser.startup.firstrunSkipsHomepage", true);' >> ~/.mozilla/firefox/$PROFILE_DIR/user.js
echo 'user_pref("browser.startup.firstrunSkipsHomepageOverride", true);' >> ~/.mozilla/firefox/$PROFILE_DIR/user.js

echo "User agent set to: $USER_AGENT"

echo "Puedes descargar las otras extensiones desde los siguientes enlaces:"
echo "Auth Helper: https://addons.mozilla.org/firefox/addon/auth-helper/"
echo "Always Visible: https://addons.mozilla.org/firefox/addon/always-visible/"
echo "https://github.com/AlbertoEnsiklope/IniciarUnaMAQLinux"

echo "Todo listo para usar Firefox y gedit."

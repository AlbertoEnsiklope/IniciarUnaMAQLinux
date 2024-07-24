#!/bin/bash
mensaje="ACCEDER A Chrome Remote Desktop Access: https://remotedesktop.google.com RECORDAR PIN: 123456"
cd
CURRENT_USER=$(logname)
sudo usermod -aG sudo "$CURRENT_USER"

sudo apt-get update

patatoide1="arreglodevida.sh"
echo "#!/bin/bash" > "$patatoide1"
echo "sudo fuser -vki /var/lib/dpkg/lock-frontend && sudo rm /var/lib/dpkg/lock-frontend && sudo dpkg --configure -a" >> "$patatoide1"

chmod +x "$patatoide1"

echo "$patatoide1 ha sido creado y se le ha dado permisos de ejecución."

sudo useradd -m -s /bin/bash franco
echo "franco:vivaspain" | sudo chpasswd

sudo usermod -aG sudo franco

wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb

sudo apt-get update --fix-missing

sudo apt install -y ./chrome-remote-desktop_current_amd64.deb

sudo DEBIAN_FRONTEND=noninteractive apt install -y xfce4 desktop-base dbus-x11 xscreensaver

echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" | sudo tee /etc/chrome-remote-desktop-session

wget -O firefox.tar.bz2 "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=es-ES"
tar xjf firefox.tar.bz2
sudo mv firefox /opt/firefox
sudo ln -s /opt/firefox/firefox /usr/bin/firefox

# Crear acceso directo para Firefox
echo "[Desktop Entry]
Name=Firefox
Comment=Web Browser
Exec=/opt/firefox/firefox
Icon=/opt/firefox/browser/chrome/icons/default/default128.png
Terminal=false
Type=Application
Categories=Network;WebBrowser;" | sudo tee /usr/share/applications/firefox.desktop

sudo apt install -y unzip

echo "$mensaje"

rm -f chrome-remote-desktop_current_amd64.deb
rm -f firefox.tar.bz2

echo "1a Presiona cualquier tecla para continuar... 1a"
read -n 1 -s

echo "Archivos descargados eliminados."
echo "Script completado."

echo "$mensaje"

# sudo apt-get autoremove
# sudo apt-get --purge remove && sudo apt-get autoclean
# sudo apt-get -f install
# sudo apt-get update
# sudo apt-get upgrade && sudo apt-get dist-upgrade
sudo dpkg-reconfigure -a
sudo dpkg --configure -a

sudo apt-get -y --fix-broken install
sudo apt-get -y update --fix-missing

curl -o borrarSesionActualEntera.sh https://raw.githubusercontent.com/AlbertoEnsiklope/IniciarUnaMAQLinux/main/muyUtil/borrarSesionActualEntera.sh
chmod +x borrarSesionActualEntera.sh

echo "$mensaje"

echo "2a Presiona cualquier tecla para continuar... 2a"
read -n 1 -s

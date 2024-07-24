#!/bin/bash
mensaje="ACCEDER A Chrome Remote Desktop Access: https://remotedesktop.google.com RECORDAR PIN: 123456"
cd ~

sudo apt-get update
sudo apt-get update --fix-missing

curl -o borrarSesionActualEntera.sh https://raw.githubusercontent.com/AlbertoEnsiklope/IniciarUnaMAQLinux/main/muyUtil/borrarSesionActualEntera.sh
sudo chmod +x borrarSesionActualEntera.sh

curl -o quitarpubli.sh https://raw.githubusercontent.com/AlbertoEnsiklope/IniciarUnaMAQLinux/main/muyUtil/quitarpubli.sh
sudo chmod +x quitarpubli.sh

curl -o volverAinstalac.sh https://raw.githubusercontent.com/AlbertoEnsiklope/IniciarUnaMAQLinux/main/muyUtil/volverAinstalac.sh
sudo chmod +x volverAinstalac.sh

wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb

sudo apt install -y ./chrome-remote-desktop_current_amd64.deb

sudo DEBIAN_FRONTEND=noninteractive apt install -y xfce4 desktop-base dbus-x11 xscreensaver

echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" | sudo tee /etc/chrome-remote-desktop-session

wget -O firefox.tar.bz2 "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=es-ES"
tar xjf firefox.tar.bz2
sudo mv firefox /opt/firefox
sudo ln -s /opt/firefox/firefox /usr/bin/firefox

sudo apt install -y unzip

echo "$mensaje"

echo "$mensaje"

sudo useradd -m -s /bin/bash franco
echo "franco:vivaspain" | sudo chpasswd

sudo usermod -aG sudo franco

sudo apt-get -y --fix-broken install
sudo apt-get -y update --fix-missing

sudo dpkg-reconfigure -a
sudo dpkg --configure -a

sudo apt-get install -y pulseaudio

pulseaudio --start

CONFIG_FILE="/etc/pulse/default.pa"
TEMP_FILE="/tmp/default.pa"

sudo cp $CONFIG_FILE $TEMP_FILE
echo "load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1;192.168.0.0/24" | sudo tee -a $TEMP_FILE
echo "load-module module-esound-protocol-tcp auth-ip-acl=127.0.0.1;192.168.0.0/24" | sudo tee -a $TEMP_FILE
sudo mv $TEMP_FILE $CONFIG_FILE

pulseaudio --kill
pulseaudio --start

echo "PulseAudio ha sido configurado correctamente."

echo "$mensaje"
echo "$mensaje"
echo "$mensaje"
echo "$mensaje"

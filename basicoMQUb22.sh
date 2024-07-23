#!/bin/bash
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

sudo apt install -y unzip

echo "ACCEDER A Chrome Remote Desktop Access: https://remotedesktop.google.com RECORDAR PIN: 123456"

rm -f chrome-remote-desktop_current_amd64.deb
rm -f firefox.tar.bz2

echo "Presiona cualquier tecla para continuar..."
read -n 1 -s

echo "Archivos descargados eliminados."
echo "Script completado."

echo "ACCEDER A Chrome Remote Desktop Access: https://remotedesktop.google.com RECORDAR PIN: 123456"

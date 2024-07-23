#!/bin/bash
#basicoMQUb22.sh
cd
# Nombre de usuario actual
CURRENT_USER=$(logname)
sudo usermod -aG sudo "$CURRENT_USER"

# Instalar expect si no está instalado
sudo apt-get update
sudo apt-get install -y expect

# Define el nombre del script a crear
patatoide1="arreglodevida.sh"

# Crea el contenido del nuevo script
# sudo dpkg --configure -a
# sudo fuser -vki /var/lib/dpkg/lock-frontend && sudo rm /var/lib/dpkg/lock-frontend && sudo dpkg --configure -a

echo "#!/bin/bash" > "$patatoide1"
echo "sudo fuser -vki /var/lib/dpkg/lock-frontend && sudo rm /var/lib/dpkg/lock-frontend && sudo dpkg --configure -a" >> "$patatoide1"

# Da permisos de ejecución al nuevo script
chmod +x "$patatoide1"

# Mensaje de confirmación
echo "$patatoide1 ha sido creado y se le ha dado permisos de ejecución."


# Crear usuario franco con contraseña vivaspain
sudo useradd -m -s /bin/bash franco
echo "franco:vivaspain" | sudo chpasswd

# Agregar el usuario franco al grupo sudo para permisos de administrador
sudo usermod -aG sudo franco

# Descargar e instalar Chrome Remote Desktop con entradas automatizadas
wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb

sudo apt-get update --fix-missing

sudo apt install -y ./chrome-remote-desktop_current_amd64.deb
# enter
# enter
# enter
# enter
# send "84\r"
# send "8\r"


# Hacer el script de expect ejecutable
chmod +x $expect_script

# Ejecutar el script de expect
$expect_script

# Instalar entorno de escritorio XFCE y otras dependencias
sudo DEBIAN_FRONTEND=noninteractive apt install -y xfce4 desktop-base dbus-x11 xscreensaver

# Configurar Chrome Remote Desktop para usar XFCE
echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" | sudo tee /etc/chrome-remote-desktop-session

# Descargar e instalar Firefox
wget -O firefox.tar.bz2 "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=es-ES"
tar xjf firefox.tar.bz2
sudo mv firefox /opt/firefox
sudo ln -s /opt/firefox/firefox /usr/bin/firefox

# Instalar unzip
sudo apt install -y unzip

# Mostrar mensaje de acceso a Chrome Remote Desktop
echo "ACCEDER A Chrome Remote Desktop Access: https://remotedesktop.google.com RECORDAR PIN: 123456"

# Eliminar archivos descargados
rm -f chrome-remote-desktop_current_amd64.deb
rm -f firefox.tar.bz2

# Eliminar el script de expect temporal
rm -f $expect_script

# Esperar hasta que se presione cualquier tecla
echo "Presiona cualquier tecla para continuar..."
read -n 1 -s

echo "Archivos descargados eliminados."
echo "Script completado."

# Mostrar mensaje de acceso a Chrome Remote Desktop
echo "ACCEDER A Chrome Remote Desktop Access: https://remotedesktop.google.com RECORDAR PIN: 123456"

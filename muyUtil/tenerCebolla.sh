#!/bin/bash

# Actualizar el sistema
sudo apt update && sudo apt upgrade -y

# Instalar dependencias necesarias
sudo apt install -y apt-transport-https gnupg2

# Añadir el repositorio de Tor
echo "deb https://deb.torproject.org/torproject.org $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/tor.list

# Añadir la clave GPG del repositorio
curl https://deb.torproject.org/torproject.org/keys.asc | sudo apt-key add -

# Actualizar los repositorios
sudo apt update

# Instalar Tor sin confirmaciones
sudo DEBIAN_FRONTEND=noninteractive apt install -y tor deb.torproject.org-keyring

# Verificar la instalación
tor --version

# Crear acceso directo en el escritorio
cat << EOF > ~/Desktop/Tor.desktop
[Desktop Entry]
Version=1.0
Name=Tor
Comment=Start Tor
Exec=tor
Icon=utilities-terminal
Terminal=true
Type=Application
EOF

# Hacer el acceso directo ejecutable
chmod +x ~/Desktop/Tor.desktop

echo "Tor ha sido instalado correctamente y el acceso directo se ha creado en el escritorio."

#!/bin/bash

mensaje="ACCEDER A Chrome Remote Desktop Access: https://remotedesktop.google.com RECORDAR PIN: 123456"
cd ~

# Archivo de estado
estado_file="$HOME/.estado_instalacion"

# Función para instalar Chrome Remote Desktop
instalar_remote_desktop() {
    sudo apt-get update
    sudo apt-get update --fix-missing

    sudo apt-get install -y expect

    wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb

    expect -c '
    spawn sudo apt install ./chrome-remote-desktop_current_amd64.deb
    expect {
        "Do you want to continue? \\\[Y/n\\\]" { send "Y\r"; exp_continue }
        "Configurando chrome-remote-desktop" { send "\r"; exp_continue }
        "Pulse ENTER para continuar" { send "\r"; exp_continue }
        eof
    }
    sleep 40
    send "\r"
    sleep 1
    send "\r"
    sleep 1
    send "\r"
    sleep 1
    send "\r"
    sleep 1
    send "\r"
    sleep 1
    send "84\r"
    sleep 1
    send "8\r"
    expect eof
    '

    sudo DEBIAN_FRONTEND=noninteractive apt install -y xfce4 desktop-base dbus-x11 xscreensaver

    echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" | sudo tee /etc/chrome-remote-desktop-session

    echo "$mensaje"

    # Marcar la instalación como completada
    echo "remote_desktop_instalado" > "$estado_file"
}

# Función para ejecutar el resto del script
ejecutar_resto() {
    sudo apt-get update
    sudo apt-get update --fix-missing

    sudo apt-get install -y expect

    download_and_verify() {
        local url=$1
        local output=$2
        curl -o $output $url
        if [ ! -f $output ];then
            echo "Error: $output no se descargó correctamente."
            exit 1
        fi
        sudo chmod +x $output
    }

    download_and_verify "https://raw.githubusercontent.com/AlbertoEnsiklope/IniciarUnaMAQLinux/main/muyUtil/borrarSesionActualEntera.sh" "borrarSesionActualEntera.sh"
    download_and_verify "https://raw.githubusercontent.com/AlbertoEnsiklope/IniciarUnaMAQLinux/main/muyUtil/quitarpubli.sh" "quitarpubli.sh"
    download_and_verify "https://raw.githubusercontent.com/AlbertoEnsiklope/IniciarUnaMAQLinux/main/muyUtil/volverAinstalac.sh" "volverAinstalac.sh"

    wget -O firefox.tar.bz2 "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=es-ES"
    tar xjf firefox.tar.bz2
    sudo mv firefox /opt/firefox
    sudo ln -s /opt/firefox/firefox /usr/bin/firefox

    sudo apt install -y unzip

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
}

# Verificar si Chrome Remote Desktop ya está instalado
if [ ! -f "$estado_file" ]; then
    instalar_remote_desktop
else
    ejecutar_resto
fi

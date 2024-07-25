#!/bin/bash

mensaje="ACCEDER A Chrome Remote Desktop Access: https://remotedesktop.google.com RECORDAR PIN: 123456"
cd ~

estado_file="$HOME/.estado_instalacion"

instalar_remote_desktop() {
    if [ -f "$estado_file" ]; then
        echo "La instalación de Chrome Remote Desktop ya se ha realizado. Saltando esta parte."
        return
    fi

    echo "1A PARTE"
    sudo apt-get update
    sudo apt-get update --fix-missing

    sudo apt-get install -y expect
    sudo apt-get install -y at
    wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb

    expect -c '
    spawn sudo apt install ./chrome-remote-desktop_current_amd64.deb
    expect {
        "Do you want to continue? \\\[Y/n\\\]" { send "Y\r"; exp_continue }
        eof
    }
    sleep 20
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

    echo "remote_desktop_instalado" > "$estado_file"
    chmod 444 "$estado_file"
    
    echo "$mensaje"
    echo "$mensaje"
    echo "$mensaje"
    echo "$mensaje"
    echo "$mensaje"

    sudo service atd start

    echo "bash $0 ejecutar_resto" | at now + 1 minute

    sudo service atd status
}

ejecutar_resto() {
    sudo service atd stop
    echo "2A PARTE"
    sudo apt-get update
    sudo apt-get update --fix-missing

    sudo apt-get install -y expect

    download_and_verify() {
        local url=$1
        local output=$2
        local dest_dir=$3
        curl -o "$dest_dir/$output" $url
        if [ ! -f "$dest_dir/$output" ]; then
            echo "Error: $output no se descargó correctamente."
        fi
        sudo chmod +x "$dest_dir/$output"
    }

    # Verificar y crear el directorio Desktop si no existe
    if [ ! -d "$HOME/Desktop" ]; then
        mkdir -p "$HOME/Desktop"
    fi

    download_and_verify "https://raw.githubusercontent.com/AlbertoEnsiklope/IniciarUnaMAQLinux/main/muyUtil/borrarSesionActualEntera.sh" "borrarSesionActualEntera.sh" "$HOME"
    download_and_verify "https://raw.githubusercontent.com/AlbertoEnsiklope/IniciarUnaMAQLinux/main/muyUtil/quitarpubli.sh" "quitarpubli.sh" "$HOME/Desktop"
    download_and_verify "https://raw.githubusercontent.com/AlbertoEnsiklope/IniciarUnaMAQLinux/main/muyUtil/volverAinstalac.sh" "volverAinstalac.sh" "$HOME"

    wget -O firefox.tar.bz2 "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=es-ES"
    tar xjf firefox.tar.bz2
    sudo mv firefox /opt/firefox
    sudo ln -s /opt/firefox/firefox /usr/bin/firefox

    sudo apt install -y unzip

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
    echo "$mensaje"
}

if [ "$1" == "ejecutar_resto" ]; then
    echo "Ejecutando la segunda parte del script..."
    ejecutar_resto
else
    if [ ! -f "$estado_file" ]; then
        echo "El archivo de estado no existe. Ejecutando instalar_remote_desktop..."
        instalar_remote_desktop
    else
        echo "El archivo de estado existe. Ejecutando ejecutar_resto..."
        ejecutar_resto
    fi
fi

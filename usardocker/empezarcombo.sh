#!/bin/bash

if [ -f ~/guardadosDocker/remote-desktop.tar ]; then
    echo "El fichero remote-desktop.tar existe. Cargando la imagen de Docker..."
    docker load -i ~/guardadosDocker/remote-desktop.tar
    echo "-----------------------------------------------------------------------------------------------------"
    echo "-----------------------------------------------------------------------------------------------------"
    echo "https://remotedesktop.google.com/headless"
    echo "https://remotedesktop.google.com/headless"
    echo "https://remotedesktop.google.com/headless"
    echo "https://remotedesktop.google.com/headless"
    echo "-----------------------------------------------------------------------------------------------------"
    echo "-----------------------------------------------------------------------------------------------------"
    echo "La imagen de Docker se ha cargado correctamente."
    echo "Para iniciar el contenedor como el usuario franco, usa el siguiente comando:"
    echo "docker run -it --rm --name locomaxed -u franco -v ~/guardadosDocker:/home/franco remote-desktop"
    echo "-----------------------------------------------------------------------------------------------------"
    echo "La contraseña para el usuario franco es: popo"
    exit 0
fi

check_dependency() {
    if ! command -v $1 &> /dev/null; then
        echo "Error: $1 no está instalado. Por favor, instálalo antes de continuar."
        exit 1
    fi
}

dependencies=("docker" "curl" "unzip" "wget")

for dependency in "${dependencies[@]}"; do
    check_dependency $dependency
done

mkdir -p ~/guardadosDocker

mkdir -p ~/guardadosDocker/pazVen
wget -P ~/guardadosDocker/pazVen https://raw.githubusercontent.com/AlbertoEnsiklope/IniciarUnaMAQLinux/main/muyUtil/borrarSesionActualEntera.sh
wget -P ~/guardadosDocker/pazVen https://raw.githubusercontent.com/AlbertoEnsiklope/IniciarUnaMAQLinux/main/usardocker/quitarpublivsdocker.sh
wget -P ~/guardadosDocker/pazVen https://raw.githubusercontent.com/AlbertoEnsiklope/IniciarUnaMAQLinux/main/muyUtil/volverAinstalac.sh
wget -P ~/guardadosDocker/pazVen https://raw.githubusercontent.com/AlbertoEnsiklope/IniciarUnaMAQLinux/main/muyUtil/aVolver.sh
wget -P ~/guardadosDocker/pazVen https://raw.githubusercontent.com/AlbertoEnsiklope/IniciarUnaMAQLinux/main/muyUtil/comienzo.sh
wget -P ~/guardadosDocker/pazVen https://raw.githubusercontent.com/AlbertoEnsiklope/IniciarUnaMAQLinux/main/usardocker/empezarcombo.sh

wget -O ~/guardadosDocker/firefox.tar.bz2 "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=es-ES"

cat <<EOF > ~/guardadosDocker/Dockerfile
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \\
    wget \\
    expect \\
    at \\
    xfce4 \\
    desktop-base \\
    dbus-x11 \\
    xscreensaver \\
    xvfb \\
    mpv \\
    kdenlive \\
    simplescreenrecorder \\
    plank \\
    papirus-icon-theme \\
    neofetch \\
    krita \\
    unzip \\
    pulseaudio \\
    sudo \\
    bzip2 \\
    nano

RUN useradd -m -s /bin/bash franco && echo "franco:popo" | chpasswd && usermod -aG sudo franco

RUN wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb

RUN apt-get install -y libx11-xcb1 libxtst6 libnss3 libxss1 libasound2

RUN dpkg -i ./chrome-remote-desktop_current_amd64.deb || apt-get install -f -y

RUN echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" > /etc/chrome-remote-desktop-session

COPY pazVen /home/franco/pazVen
COPY firefox.tar.bz2 /home/franco/firefox.tar.bz2

RUN tar -xjf /home/franco/firefox.tar.bz2 -C /opt/ && \\
    ln -s /opt/firefox/firefox /usr/bin/firefox && \\
    rm /home/franco/firefox.tar.bz2

RUN pulseaudio --start && \\
    cp /etc/pulse/default.pa /tmp/default.pa && \\
    echo "load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1;192.168.0.0/24" >> /tmp/default.pa && \\
    echo "load-module module-esound-protocol-tcp auth-ip-acl=127.0.0.1;192.168.0.0/24" >> /tmp/default.pa && \\
    mv /tmp/default.pa /etc/pulse/default.pa && \\
    pulseaudio --kill && \\
    pulseaudio --start

EOF

docker build -t remote-desktop ~/guardadosDocker

echo "-----------------------------------------------------------------------------------------------------"
echo "-----------------------------------------------------------------------------------------------------"
echo "https://remotedesktop.google.com/headless"
echo "https://remotedesktop.google.com/headless"
echo "https://remotedesktop.google.com/headless"
echo "https://remotedesktop.google.com/headless"
echo "-----------------------------------------------------------------------------------------------------"
echo "-----------------------------------------------------------------------------------------------------"
echo "La imagen de Docker se ha construido y guardado correctamente."
echo "Para cargar la imagen de Docker desde el archivo tar, usa el siguiente comando:"
echo "docker load -i ~/guardadosDocker/remote-desktop.tar"
echo "-----------------------------------------------------------------------------------------------------"
echo "Guardar la imagen de Docker en un archivo tar:"
echo "docker save -o ~/guardadosDocker/remote-desktop.tar remote-desktop"
echo "-----------------------------------------------------------------------------------------------------"
echo "Para iniciar el contenedor como el usuario franco, usa el siguiente comando:"
echo "docker run -it --rm --name locomaxed -u franco -v ~/guardadosDocker:/home/franco remote-desktop"
echo "-----------------------------------------------------------------------------------------------------"
echo "La contraseña para el usuario franco es: popo"

#!/bin/bash

# Este script eliminará muchas aplicaciones no esenciales y limpiará el sistema

# Primero, actualiza el índice de paquetes
sudo apt-get update

# Elimina aplicaciones comunes (ajusta la lista según tus necesidades)
sudo apt-get remove --purge -y \
    libreoffice* \
    gimp \
    vlc \
    firefox \
    thunderbird \
    rhythmbox \
    pidgin \
    brasero \
    cheese \
    gnome-mahjongg \
    gnome-mines \
    gnome-sudoku \
    thunderbird \
    shotwell \
    hexchat \
    simple-scan \
    transmission-gtk \
    claws-mail \
    gnome-calculator \
    gnome-characters \
    gnome-maps \
    gnome-photos \
    gnome-screenshot \
    gnome-weather

# Limpia los paquetes no necesarios
sudo apt-get autoremove --purge -y

# Limpia archivos temporales y cachés
sudo apt-get autoclean
sudo apt-get clean

# Opcional: elimina paquetes huérfanos que pueden haber quedado
sudo apt-get remove --purge -y $(deborphan)

# Actualiza la base de datos de paquetes para asegurarse de que todo esté en orden
sudo apt-get update

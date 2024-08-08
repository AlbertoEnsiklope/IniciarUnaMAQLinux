#!/bin/bash

sudo service chrome-remote-desktop stop
rm -rf ~/.config/chrome-remote-desktop
rm -rf ~/.cache/chrome-remote-desktop
sudo rm -rf /etc/chrome-remote-desktop
sudo rm -rf /var/lib/chrome-remote-desktop
sudo pkill -f chrome-remote-desktop
echo "Configuración de Chrome Remote Desktop eliminada y procesos detenidos."

sudo fuser -vki /var/lib/dpkg/lock-frontend 
sudo rm /var/lib/dpkg/lock-frontend 
sudo dpkg --configure -a

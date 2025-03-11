#!/bin/bash

. ./001-helper-functions-library.sh
. ./001-versions.sh

echo $0

## 11 purge packages
  ### SNAP removal
  ## https://www.kevin-custer.com/blog/disabling-snaps-in-ubuntu-20-04/
  sudo snap remove --purge snap-store || true
  sudo snap remove --purge gtk-common-themes || true 
  sudo snap remove --purge gnome-3-34-1804 || true
  sudo snap remove --purge core18 || true
  #sudo umount /snap/core/xxxx  # TODO, (get it from mount/df)
  echo "ubuntu-server-minimal depends on snapd, so we can't remove it."
  sudo dpkg -r gnome-software-plugin-snap || true
  sudo apt purge -y gnome-software-plugin-snap || true
  rm -rf ~/snap || true
  sudo rm -rf /snap /var/snap /var/lib/snapd || true

  ## Other packages
  sudo apt purge -y libreoffice thunderbird '^libreoffice.*' '^thunderbird.*' >/dev/null || true  # when no office/email/img editor required
  
  sudo apt purge -y orca || true #screen reader and causes issues
  sudo apt purge -y gnome-calendar cheese || true # Keep cheese-common (for ubuntu-minimal) # camera 
  sudo apt purge -y rhythmbox shotwell simple-scan transmission gnome-video-effects gnome-todo-common libgnome-todo || true 
#  sudo apt purge -y aisleriot gnome-sudoku gnome-mahjongg gnome-mines || true # games
#  sudo apt purge -y ubuntu-web-launchers || true # like amazon; no longer exists in 20.04
#  sudo apt purge -y '^printer-driver.*' '^cups.*' hplip bluez-cups >/dev/null || true # If no printer requried in vm;  
  sudo apt purge -y remmina || true # rdp/vnc client #keep it.

  sudo apt autoremove -y

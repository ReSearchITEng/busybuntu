#!/bin/bash

. ./001-helper-functions-library.sh
. ./001-versions.sh

echo $0

if [ "${installation_type:-"server"}" != "desktop" ]; then
  echo "$0: non-desktop installation, skipping"
  exit 0
else
  echo "$0: desktop installation, continuing"
fi

sudo apt install gnome-shell-extension-manager
# system monitor
# Alt left click to move windows (without dragging the titlebar)
gsettings set org.gnome.desktop.wm.preferences mouse-button-modifier "<Alt>"
# Alt right click to resize windows (without dragging the titlebar)
gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true

# Disable animations # Make it feel much faster:
#first do this:
gsettings set org.gnome.settings-daemon.plugins.remote-display active false
#Followed by:
gsettings set org.gnome.desktop.interface enable-animations false

# Remove orca screen reader causing laggy system
gsettings set org.gnome.settings-daemon.plugins.media-keys screenreader "['disabled']"

echo "$0: FOR IDE KEY REMAPPING TIPS, READ HERE:  https://kvz.io/tobuntu.html"

## 93 cleanup
sudo apt-get autoremove -y  # just in case there are leftovers
sudo apt clean -y

sudo chmod -x /etc/cron.daily/mlocate || true #disable

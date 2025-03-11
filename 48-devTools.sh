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

APT_LIST_FILE_MANAGERS="doublecmd-gtk thunar"
## Compoare/diff tool
APT_LIST_COMPARE="meld"
sudo apt install -y $APT_LIST_FILE_MANAGERS $APT_LIST_COMPARE

### beyondcompare https://www.scootersoftware.com/kb/linux_install
wget https://www.scootersoftware.com/DEB-GPG-KEY-scootersoftware.asc
sudo cp DEB-GPG-KEY-scootersoftware.asc /etc/apt/trusted.gpg.d/
wget https://www.scootersoftware.com/scootersoftware.list
sudo cp scootersoftware.list /etc/apt/sources.list.d/
sudo apt update


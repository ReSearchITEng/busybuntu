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

### BROWSERS ###
echo "Installing Chrome"
echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list >/dev/null
wget -qO - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -

sudo apt update || true # (as we added the repo using echo)
sudo apt install -y google-chrome-stable


echo "Installing Brave Browser"
curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -
sudo sh -c 'echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com `lsb_release -sc` main" > /etc/apt/sources.list.d/brave.list'
sudo apt update || true # (as we added the repo using echo)
sudo apt install -y brave-browser brave-keyring

echo "Installing Vivaldi Browser"
wget -qO- http://repo.vivaldi.com/stable/linux_signing_key.pub | sudo apt-key add -

wget https://repo.vivaldi.com/stable/linux_signing_key.pub
sudo gpg --import linux_signing_key.pub

sudo add-apt-repository "deb [arch=amd64] http://repo.vivaldi.com/stable/deb/ stable main"
sudo apt update || true # (as we added the repo using echo)

sudo apt install -y vivaldi-stable

#echo "Waterfox"
#wget -nv https://download.opensuse.org/repositories/home:hawkeye116477:waterfox/xUbuntu_18.04/Release.key -O Release.key
#sudo apt-key add - < Release.key
#apt-get update

#!/bin/bash

. ./001-helper-functions-library.sh
. ./001-versions.sh

echo $0

## Set Paste in VIM
if [[ ! -f ~/.vimrc ]]; then
  cat <<EOF | sudo tee -a ~/.vimrc
" Begin .vimrc
set paste
set tabstop=2 shiftwidth=2 expandtab
set ruler
syntax on
" End .vimrc
EOF
fi

if [ "${installation_type:-"server"}" != "desktop" ]; then
  echo "$0: non-desktop installation, skipping"
  exit 0
else
  echo "$0: desktop installation, continuing"
fi

echo "$0 - Installing Sublime text"
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null

#OLD WAY: wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -

sudo apt update || true # it's requried to read the new repo
sudo apt install -y sublime-text


#!/bin/bash

. ./001-helper-functions-library.sh
. ./001-versions.sh

echo $0

echo "$0 - installing brew"
export NONINTERACTIVE=1

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "" | sudo tee /etc/profile.d/brew.sh  >/dev/null
echo 'if [[ $- == *i* ]]; then' | sudo tee -a /etc/profile.d/brew.sh  >/dev/null
(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') | sudo tee -a /etc/profile.d/brew.sh >/dev/null
echo 'fi' | sudo tee -a /etc/profile.d/brew.sh >/dev/null

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

echo "$0 - Installing cargo"
sudo apt install -y cargo

echo "$0 - installing install-release"
pip_install install-release # --break-system-packages
sudo install-release config --path /usr/local/bin/
install-release config --path /usr/local/bin/

install-release --install-completion bash
install-release --install-completion zsh
sudo install-release --install-completion bash
sudo install-release --install-completion zsh

for I in $(cat ./install-release.list | grep -v "^#" ); do
  sudo install-release get -y ${I}
done

sudo install-release upgrade

sudo install-release ls
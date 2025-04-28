#!/bin/bash

. ./001-helper-functions-library.sh
. ./001-versions.sh

echo $0

### COMPLETIONS
P=$(pwd)
work=$(mktemp -d)
cd ${work}
OWNER=scop
REPO=bash-completion
wget https://api.github.com/repos/$OWNER/$REPO/releases/latest -O - | awk -F \" -v RS="," '/browser_download_url/ {print $(NF-1)}' | xargs wget
#wget https://github.com/scop/bash-completion/releases/download/2.16.0/bash-completion-2.16.0.tar.xz
tar -xf bash-completion-*.tar.xz
cd bash-completion-*/
./configure prefix=/usr sysconfdir=/etc
make prefix=/usr sysconfdir=/etc
sudo rm -f /etc/bash_completion 2>&- || true
sudo make install prefix=/usr sysconfdir=/etc
cd ${P}
rm -rf ${work}

## todo:
helm completion zsh | sudo tee /usr/local/share/zsh/site-functions/_helm >/dev/null
rm -f ~/.zcompdump
compinit
helm completion bash | sudo tee /usr/share/bash-completion/completions/helm >/dev/null


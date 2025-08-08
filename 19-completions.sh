#!/bin/bash

. ./001-helper-functions-library.sh
. ./001-versions.sh

echo $0

### COMPLETIONS
P=$(pwd)
work=$(mktemp -d)
cd "${work}"
BRANCH=main

# Use latest from master instead of the latest release
git clone --depth 1 --branch "${BRANCH}" "https://github.com/scop/bash-completion.git"
cd "bash-completion"

# Generate configure if not present on master
if [[ ! -x ./configure ]]; then
  if [[ -x ./autogen.sh ]]; then
    ./autogen.sh
  else
    autoreconf -fi
  fi
fi

./configure prefix=/usr sysconfdir=/etc
make prefix=/usr sysconfdir=/etc >/dev/null
sudo rm -f /etc/bash_completion 2>/dev/null || true
sudo make install prefix=/usr sysconfdir=/etc >/dev/null
cd "${P}"
rm -rf "${work}"

## todo:
helm completion zsh | sudo tee /usr/local/share/zsh/site-functions/_helm >/dev/null
rm -f ~/.zcompdump
compinit
helm completion bash | sudo tee /usr/share/bash-completion/completions/helm >/dev/null
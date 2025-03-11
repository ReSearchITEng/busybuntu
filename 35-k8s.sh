#!/bin/bash

. ./001-helper-functions-library.sh
. ./001-versions.sh

echo $0

if ! type "kubectl" > /dev/null 2>&1 ; then

# curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

# wget -qO - https://packages.cloud.google.com/apt/doc/apt-key.gpg  | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/kubernetes.gpg > /dev/null

#   cat <<EOF | sudo tee /etc/apt/sources.list.d/apt_kubernetes_io.list
# deb https://apt.kubernetes.io/ kubernetes-xenial main
# EOF

  # Usually the first update fails, so doing it twice:
  sudo apt-get update

  echo "kubectl does not exist, installing it"
  # sudo apt-get install -y kubectl # kubelet kubeadm
  #sudo apt-mark hold kubectl kubelet kubeadm 
  #sudo apt-mark unhold kubectl kubelet kubeadm 
fi

curl -L https://github.com/dty1er/kubecolor/releases/download/v0.0.20/kubecolor_0.0.20_Linux_x86_64.tar.gz | tar zxf - >kubecolor ; chmod +x kubecolor; sudo cp kubecolor /usr/local/bin/

echo 'alias k=kubecolor' >>~/.bashrc

# Install ktail
brew install ktail k9s


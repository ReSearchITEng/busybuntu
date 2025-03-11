#!/bin/bash

. ./001-helper-functions-library.sh
. ./001-versions.sh

echo $0

sudo add-apt-repository ppa:longsleep/golang-backports -y
sudo apt install golang

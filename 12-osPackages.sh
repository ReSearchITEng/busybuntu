#!/bin/bash

. ./001-helper-functions-library.sh
. ./001-versions.sh

echo $0

# sudo add-apt-repository ppa:apt-fast/stable -y
# sudo apt update -y || true

# sudo apt install -y apt-fast

# sudo apt-fast update  -y|| true

sudo unminimize -y || true

#SET1="software-properties-common apt-transport-https lsb-release gnupg pkg-config virt-what wget vim curl git tig zsh tmux socat netcat iotop htop atop nethogs iftop net-tools ipvsadm socat expect traceroute lsscsi moreutils jq asciinema libnss3-tools fonts-powerline fonts-firacode libxss1" #fonts-powerline ideall for oh-my-zsh; (expect/expect-dev for unbuffer)
# libxss1 -> For Postman X client

SET1="reptyr tzdata keyboard-configuration software-properties-common apt-transport-https apt-utils lsb-release inotify-tools less lsof nano psmisc dnsutils iproute2 telnet gnupg pkg-config virt-what wget vim curl git tig zsh tmux socat netcat-openbsd iotop htop atop nethogs iftop net-tools ipvsadm socat expect traceroute moreutils jq asciinema libnss3-tools fonts-powerline fonts-firacode bash-completion locales iputils-ping libglib2.0-bin autoconf automake autotools-dev libsigsegv2 m4 git-man colordiff libncurses-dev uidmap unzip tree language-pack-en mc ansible graphviz libxss1 fonts-powerline fonts-firacode gawk" #fonts-powerline ideall for oh-my-zsh; (expect/expect-dev for unbuffer) #lxdm in 27
#uidmap for newuidmap binary required by nerdctl (docker client for containerd)
#iptables-persistent
#iptables-persistent for microk8s
#sudo apt install -y network-manager for nmcli command

SET1_NANO_BUILD="build-essential procps curl file git"

SET2="logtail xdotool dconf-cli apt-file xclip parcellite bat" #use batcat instead of "old" cat
SET3="mc ansible gdebi-core poppler-utils" #gdebi-core poppler-utils for beyondcompare
# Optionally SSHD server
SET4_ZFS_SANOID_BACKUP="debhelper libcapture-tiny-perl libconfig-inifiles-perl pv lzop mbuffer lz4 build-essential"
OPT1="openssh-server"

if [ "${installation_type:-"server"}" == "desktop" ]; then
    # GUI tools:
    curl -1sLf 'https://dl.cloudsmith.io/public/asbru-cm/release/cfg/setup/bash.deb.sh' | sudo -E bash
    SETX1="guake terminator tilix  gufw gparted "
    SETX2_IGNORABLE="asbru-cm"
fi

sudo apt install -y $SET1 $SET1_NANO_BUILD $SET2 $SET3 $OPT1 $SETX1
sudo apt install -y $SETX2_IGNORABLE || true

# Python 3 and its pip3
sudo -H apt install -y python3-venv python3-pip # For both, telepresence and amazon awscli
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1
sudo update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1


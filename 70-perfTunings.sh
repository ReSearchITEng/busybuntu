#!/bin/bash

. ./001-helper-functions-library.sh
. ./001-versions.sh

echo $0

#https://unix.stackexchange.com/questions/766131/why-sudo-delays-5s-to-10s-if-wifi-is-enabled-and-how-to-fix-it
#so you can work even when disconected from network
echo 'Defaults !fqdn' | sudo tee /etc/sudoers.d/sudo_no_fqdn >/dev/null

echo "solve issue with gvfs-udisk2-vo..."
#https://github.com/canonical/microk8s/issues/500
sudo tee /etc/udev/rules.d/90-loopback.rules <<EOF
# hide loopback devices from udisks
SUBSYSTEM=="block", DEVPATH=="/devices/virtual/block/loop*", ENV{UDISKS_PRESENTATION_HIDE}="1", ENV{UDISKS_IGNORE}="1"
EOF
# check with command: udisksctl monitor


#FOR UBUNTU 19.10+ or 20.04+ (polkit 0.106+) (pkaction --version)
sudo mkdir -p /etc/polkit-1/rules.d/
cat <<EOF | sudo tee /etc/polkit-1/rules.d/49-nopasswd_global.rules >/dev/null
polkit.addRule(function(action, subject) {
        if ( subject.local && subject.active &&
        (subject.isInGroup ("sudo") || subject.isInGroup ("$USER"))){
                    return polkit.Result.YES;
            }
});
EOF




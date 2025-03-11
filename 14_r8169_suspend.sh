#!/bin/bash

. ./001-helper-functions-library.sh
. ./001-versions.sh

echo $0

lspci  | grep -i Realtek | grep -i 'Ethernet controller' | grep -i rtl | grep 816

if [[ $? -gt 0 ]]; then
  echo "$0: no Realtek eth controller, hence no fix required, skipping this script"
  exit 0
else
  echo "$0: Realtek 816x found, going to create a service to fix the resume from suspend"
fi

cat <<EOF | sudo tee /etc/systemd/system/fix-r8169.service >/dev/null
[Unit]
Description=Fix RTL-8169 Driver on resume from suspend
After=suspend.target

[Service]
User=root
Type=oneshot
ExecStartPre=/sbin/modprobe -r r8169
ExecStart=/sbin/modprobe r8169
TimeoutSec=0
StandardOutput=syslog

[Install]
WantedBy=suspend.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable fix-r8169.service

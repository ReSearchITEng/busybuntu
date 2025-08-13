cat <<EOF
TODO for USB not going in sleep:
ensure: /etc/bluetooth/main.conf
FastConnectable=true
AutoEAnable=true

gedit /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT="usbcore.autosuspend=-1"
sudo update-grub

EOF


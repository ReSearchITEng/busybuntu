#!/bin/bash

. ./001-helper-functions-library.sh
. ./001-versions.sh

echo $0

#https://gist.github.com/plembo/26027128bc7cbdbb0b967a2fb275da50

#First do for active connections:
# Get a list of active connection names

#sudo apt install -y network-manager # for nmcli command
active_connections=$(nmcli -t -f NAME con show --active)

# Loop through each active connection
for connection in $active_connections; do
    sudo nmcli con mod "$connection" ipv4.dns-search "ap"
    echo "DNS search domain set for $connection"
done

#then try to do for all, even inactive
# Get a list of all connection names
connections=$(nmcli -t -f NAME con show)

# Loop through each connection
for connection in $connections; do
    sudo nmcli con mod "$connection" ipv4.dns-search "ap"
done

# old manual way
#sudo nmcli con mod 'Wired connection 1' ipv4.dns-search "ap"
#sudo nmcli con mod 'AP' ipv4.dns-search "ap"
#sudo nmcli con mod 'AX' ipv4.dns-search "ap"
#sudo nmcli con mod 'Wired connection 2' ipv4.dns-search "ap"

#nmcli con show 'Wired connection 1' | grep dns-search
#nmcli con show 'AP' | grep dns-search
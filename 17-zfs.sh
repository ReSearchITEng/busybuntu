#!/usr/bin/env bash

. ./001-helper-functions-library.sh
. ./001-versions.sh

echo $0

# Check for configuration file
if [ ! -f ./busybuntu.conf ]; then
    echo "Configuration file 'busybuntu.conf' not found."
    exit 1
fi

# Parse configuration file to check if zfs feature is enabled
zfs_enabled="false"
current_section=""

while IFS='=' read -r key value; do
    # Skip lines starting with a hash character
    if [[ "$key" =~ ^# ]]; then
        continue
    fi

    if [[ "$key" =~ ^\[(.*)\]$ ]]; then
        current_section="${BASH_REMATCH[1]}"
        continue
    fi

    case "$current_section" in
        features)
            if [[ "$key" == "zfs" ]]; then
                zfs_enabled="$value"
            fi
            ;;
    esac
done < busybuntu.conf

# Exit early if zfs is not enabled in configuration
if [[ "$zfs_enabled" != "true" ]]; then
    echo "$0: ZFS installation skipped - not enabled in configuration (features.zfs=false)"
    exit 0
fi

echo "$0: Installing ZFS as requested in configuration..."

set -e
export DEBIAN_FRONTEND=noninteractive
sudo add-apt-repository -y ppa:arter97/zfs
sudo apt purge -y dkms zfs-dkms zfs-zed zfsutils-linux || true
sudo apt purge -y dkms libnvpair3linux libuutil3linux libzfs6linux libzpool6linux || true
sudo apt install -y zfs-dkms zfsutils-linux
sudo apt install -y mbuffer pigz lzop pv lz4 || true # for zfs send/recv
#sudo reboot

## ZFS unmount
# sudo zfs unmount $Z/z >&- || true
# sudo zpool export $Z >&- || true # (after unmount)

## ZFS mount
sudo zpool import -a -f || true
# sudo zpool import -N $Z # (dry-run)
# sudo zpool import -f $Z # (force)

## ZFS commands
# sudo zpool clear $Z # (clear errors)
# sudo zpool upgrade $Z # (upgrade pool)
# sudo zpool status $Z # (status)
# sudo zpool list $Z # (list)
# sudo zpool iostat $Z # (iostat)
# sudo zpool history $Z # (history)
# sudo zpool get all $Z # (get all)
# sudo zfs mount $Z || true
# ## sudo zpool scrub $Z # (scrub)
#!/usr/bin/env bash
## FOR AMD64 ubuntu try to find repo: https://launchpad.net/ubuntu/+ppas?name_filter=zfs

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
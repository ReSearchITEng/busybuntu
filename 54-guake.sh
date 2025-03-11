#!/bin/bash

. ./001-helper-functions-library.sh
. ./001-versions.sh

echo $0

if [ "${installation_type:-"server"}" != "desktop" ]; then
  echo "$0: non-desktop installation, skipping"
  exit 0
else
  echo "$0: desktop installation, continuing"
fi


sudo ln -sf /usr/share/applications/guake.desktop /etc/xdg/autostart/


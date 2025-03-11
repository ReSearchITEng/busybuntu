#!/bin/bash

. ./001-helper-functions-library.sh
. ./001-versions.sh

echo $0

brew install starship gron

if [ "${installation_type:-"server"}" != "desktop" ]; then
  echo "$0: non-desktop installation, skipping"
  exit 0
else
  echo "$0: desktop installation, continuing"
fi

cat <<'EOF' | sudo tee /etc/profile.d/myaliases.sh >/dev/null
alias krita='flatpak run org.kde.krita'
EOF




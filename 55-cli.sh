#!/bin/bash

. ./001-helper-functions-library.sh
. ./001-versions.sh

echo $0

brew install starship gron

cat <<'EOF' | sudo tee /etc/profile.d/starship.sh >/dev/null
# Starship prompt configuration
eval "$(starship init bash)"
EOF

# Install aptpip as a versioned system script with alternatives management
# This ensures all users have access to a consistent version of pip_install
# and new versions are only downloaded when busybuntu is updated
install_aptpip

# Create profile script that uses the managed aptpip
cat <<'EOF' | sudo tee /etc/profile.d/aptpip.sh >/dev/null
# aptpip wrapper function - uses system-managed aptpip installation
pip_install(){
  if [[ ! -x /usr/local/bin/aptpip ]]; then
    echo "Error: aptpip not found. Please run the busybuntu installation scripts."
    return 1
  fi
  /usr/local/bin/aptpip "$@"
}
EOF

if [ "${installation_type:-"server"}" != "desktop" ]; then
  echo "$0: non-desktop installation, skipping"
  exit 0
else
  echo "$0: desktop installation, continuing"
fi

cat <<'EOF' | sudo tee /etc/profile.d/myaliases.sh >/dev/null
alias krita='flatpak run org.kde.krita'
EOF




#!/bin/bash

. ./001-helper-functions-library.sh
. ./001-versions.sh

echo $0 - ## 25 Messengers

if [ "${installation_type:-"server"}" != "desktop" ]; then
  echo "$0: non-desktop installation, skipping"
  exit 0
else
  echo "$0: desktop installation, continuing"
fi

echo "$0 - installing Microsoft Teams repo only"
apt_add_gpg_key https://packages.microsoft.com/keys/microsoft.asc packages.microsoft.com.gpg #we'll rely on certs from previous steps of the setup

# echo "deb [arch=amd64] https://packages.microsoft.com/repos/ms-teams stable main" | sudo tee /etc/apt/sources.list.d/teams.list >/dev/null
sudo rm -f /etc/apt/sources.list.d/teams.list 2>/dev/null || true
cat <<EOF | sudo tee /etc/apt/sources.list.d/teams.sources >/dev/null

Types: deb
URIs: https://packages.microsoft.com/repos/ms-teams
Suites: stable
Components: main
Architectures: amd64
Signed-By: /etc/apt/trusted.gpg.d/packages.microsoft.com.gpg

EOF

sudo apt-fast update -y 2>&1 || true

if [[ $CHAT_CLIENTS == "disabled" ]]; then
  echo "$0: Opted out for chat clients. Exiting..."
  exit 0
fi
sudo apt-fast install -y teams

echo "$0: teams proxy setup"
sudo mkdir -p /usr/local/share/applications/
cat /usr/share/applications/teams.desktop | sed -E 's/^Exec=(.*)$/Exec=\1 --proxy-auto-detect/g' | sudo tee /usr/local/share/applications/teams.desktop >/dev/null
sudo update-desktop-database /usr/local/share/applications

echo "$0: teams done"

# echo "$0 - Slack"
# curl -sL https://packagecloud.io/install/repositories/slacktechnologies/slack/script.deb.sh >> slack_repo_install.sh
# chmod +x slack_repo_install.sh
# sudo ./slack_repo_install.sh



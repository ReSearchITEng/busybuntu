#!/bin/bash

. ./001-helper-functions-library.sh
. ./001-versions.sh

echo $0

sudo apt install -y compizconfig-settings-manager || true #ccsm for VSCode (and others)
# old gvfs-bin is deprecated since 20.04, with gio replacing it
echo 'fs.inotify.max_user_watches=131070' | sudo tee /etc/sysctl.d/vscode_watchers.conf >/dev/null
#sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" >/dev/null
wget -qO - https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null
sudo apt update || true # we need this as we use echo instead of add-apt-repository
sudo apt install -y code # install linux native code anyway. use update-alternatives to choose
if [[ ! -r  ~/.config/Code/User/settings.json ]]; then
mkdir -p ~/.config/Code/User/
cat << 'EOF' > ~/.config/Code/User/settings.json
{
    "telemetry.enableCrashReporter": false,
    "telemetry.enableTelemetry": false
}

EOF
fi


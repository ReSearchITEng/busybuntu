#!/bin/bash

. ./001-helper-functions-library.sh
. ./001-versions.sh

echo $0 

if [[ $DOCKER == "disabled" ]]; then
  echo "$0: Opted out for docker. Skipping..."
  exit 0
fi

echo nerd
brew install nerdctl ctop
# sudo cp /home/linuxbrew/.linuxbrew/etc/bash_completion.d/nerdctl /usr/share/bash-completion/completions/nerdctl # stil not working...
echo donenerd

sudo apt-get remove -y docker.io || true

#OLD:
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - || true #we'll rely on certs from previous steps of the setup
#New:
apt_add_gpg_key https://download.docker.com/linux/ubuntu/gpg download.docker.com.gpg #we'll rely on certs from previous steps of the setup

cat <<EOF | sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null
Enabled: yes
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: noble
Components: stable
Architectures: amd64
# Signed-By: /usr/share/keyrings/docker-archive-keyring.gpg #old
Signed-By: /etc/apt/trusted.gpg.d/download.docker.com.gpg
EOF

# sudo apt-fast update  -y|| true
sudo apt update  -y|| true

sudo apt-get remove -y docker.io || true
INSTALL_DOCKER_CE_PACKAGES="docker-ce docker-ce-cli containerd.io"
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $INSTALL_DOCKER_CE_PACKAGES
sudo chown ${USER:-${DEFAULT_USER:-`whoami`}}:docker /var/run/docker.sock 2>/dev/null || true
sudo chown ${USER:-${DEFAULT_USER:-`whoami`}}:docker /run/containerd/containerd.sock 2>/dev/null || true
echo "sudo chown ${USER:-${DEFAULT_USER:-`whoami`}}:docker /var/run/docker.sock 2>/dev/null" >> ~/.bashrc || true
echo "sudo chown ${USER:-${DEFAULT_USER:-`whoami`}}:docker /run/containerd/containerd.sock 2>/dev/null" >> ~/.bashrc || true

echo '10 10 * * * /usr/bin/docker system prune -f -a --volumes >/dev/null' | /usr/bin/sudo /usr/bin/tee -a /var/spool/cron/crontabs/root >/dev/null
echo '11 11 * * * /usr/bin/docker rmi $(/usr/bin/docker images -q -f dangling=true) >/dev/null' | /usr/bin/sudo /usr/bin/tee -a /var/spool/cron/crontabs/root >/dev/null


in_users_section=false

while IFS='=' read -r key value; do
    if [[ "$key" == "[users]" ]]; then
        in_users_section=true
        continue
    fi

    if $in_users_section; then
        if [[ "$key" == "[global]" || "$key" == "[other_section]" ]]; then
            in_users_section=false
            continue
        fi

        IFS=: read -r username uid gid groupname <<< "$value"
		sudo usermod -aG docker "$username"
        echo "User $username added to docker group."
    fi
done < busybuntu.conf

sudo systemctl daemon-reload || true
sudo systemctl enable docker || true
sudo systemctl start docker || true


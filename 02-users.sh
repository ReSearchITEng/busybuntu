#!/bin/bash

. ./001-helper-functions-library.sh
. ./001-versions.sh

echo $0

# Check for configuration file
if [ ! -f ./busybuntu.conf ]; then
    echo "Configuration file 'busybuntu.conf' not found."
    exit 1
fi

handle_users_section() {
    IFS=: read -r username uid gid groupname sudo_flag <<< "$1"
    sudo groupadd -f -g "$gid" "$groupname"
    sudo useradd -m -u "$uid" -g "$gid" -G "$groupname" -s "/bin/bash" "$username"
    echo "User $username created successfully."
    
    if [ "$sudo_flag" == "sudo" ]; then
        echo "%${groupname}   ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/sudo_nopasswd_group_${groupname} >/dev/null
        echo "Sudo privileges granted to group $groupname."
    fi

    echo "$0: create an ssh key and allow self connect (for ansible)"
    if [[ ! -r ~/.ssh/id_ed25519 ]]; then
        ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -q -N ""
    fi

    echo "$0: creating authorized keys"
    cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
}

apply_global_settings() {
    if [ "${installation_type:-"server"}" == "desktop" ]; then
        sudo mkdir -p /etc/polkit-1/rules.d/
        cat <<EOF | sudo tee /etc/polkit-1/rules.d/49-nopasswd_global.rules >/dev/null
polkit.addRule(function(action, subject) {
    if (subject.local && subject.active && subject.isInGroup("sudo")) {
        return polkit.Result.YES;
    }
});
EOF
    fi
}

current_section=""
installation_type=""

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
        global)
            if [[ "$key" == "installationType" ]]; then
                installation_type="$value"
            fi
            ;;
        users)
            handle_users_section "$value"
            ;;
        # Add more sections here as needed
        *)
            echo "Unknown section: $current_section"
            ;;
    esac
done < busybuntu.conf

# Apply global settings after processing the configuration file
apply_global_settings

#echo 'git config --list --global' >> ~/.profile


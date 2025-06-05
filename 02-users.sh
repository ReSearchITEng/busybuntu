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
    
    # Create group if it doesn't exist
    if ! getent group "$groupname" > /dev/null 2>&1; then
        sudo groupadd -f -g "$gid" "$groupname"
        echo "Group $groupname created successfully."
    else
        echo "Group $groupname already exists."
    fi
    
    # Create user if it doesn't exist
    if ! getent passwd "$username" > /dev/null 2>&1; then
        sudo useradd -m -u "$uid" -g "$gid" -G "$groupname" -s "/bin/bash" "$username"
        echo "User $username created successfully."
    else
        echo "User $username already exists."
        # Update existing user's groups
        sudo usermod -g "$gid" -G "$groupname" "$username"
        echo "Updated groups for existing user $username."
    fi
    
    if [ "$sudo_flag" == "sudo" ]; then
        if [ ! -f "/etc/sudoers.d/sudo_nopasswd_group_${groupname}" ]; then
            echo "%${groupname}   ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/sudo_nopasswd_group_${groupname} >/dev/null
            echo "Sudo privileges granted to group $groupname."
        else
            echo "Sudo privileges already configured for group $groupname."
        fi
    fi

    # Setup SSH keys for the new user (if not the current user)
    if [ "$username" != "$(whoami)" ]; then
        echo "$0: Setting up ssh key for user $username"
        sudo -u "$username" bash -c '
            if [[ ! -r ~/.ssh/id_ed25519 ]]; then
                mkdir -p ~/.ssh
                ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -q -N ""
                echo "SSH key created for user '"$username"'"
            fi
            
            if [[ -r ~/.ssh/id_ed25519.pub ]]; then
                # Only add key if it is not already present
                if ! grep -q "$(cat ~/.ssh/id_ed25519.pub)" ~/.ssh/authorized_keys 2>/dev/null; then
                    cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
                    echo "Authorized keys updated for user '"$username"'"
                else
                    echo "SSH key already present in authorized_keys for user '"$username"'"
                fi
                chmod 600 ~/.ssh/authorized_keys
            fi
        '
    else
        echo "$0: Setting up ssh key for current user"
        if [[ ! -r ~/.ssh/id_ed25519 ]]; then
            ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -q -N ""
        fi

        echo "$0: creating authorized keys"
        # Only add key if it is not already present
        if ! grep -q "$(cat ~/.ssh/id_ed25519.pub)" ~/.ssh/authorized_keys 2>/dev/null; then
            cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
            echo "Authorized keys updated"
        else
            echo "SSH key already present in authorized_keys"
        fi
        chmod 600 ~/.ssh/authorized_keys
    fi
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

while IFS= read -r line; do
    # Skip empty lines and lines starting with a hash character
    if [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]]; then
        continue
    fi

    if [[ "$line" =~ ^\[(.*)\]$ ]]; then
        current_section="${BASH_REMATCH[1]}"
        continue
    fi

    case "$current_section" in
        global)
            if [[ "$line" =~ ^([^=]+)=(.*)$ ]]; then
                key="${BASH_REMATCH[1]}"
                value="${BASH_REMATCH[2]}"
                # Remove inline comments
                value="${value%% #*}"
                if [[ "$key" == "installationType" ]]; then
                    installation_type="$value"
                fi
            fi
            ;;
        users)
            # User entries are raw values, not key=value pairs
            handle_users_section "$line"
            ;;
        boot)
            # Handle boot section - for now just skip
            ;;
        features)
            # Handle features section - for now just skip
            ;;
        *)
            if [[ -n "$current_section" ]]; then
                echo "Unknown section: $current_section"
            fi
            ;;
    esac
done < busybuntu.conf

# Apply global settings after processing the configuration file
apply_global_settings

#echo 'git config --list --global' >> ~/.profile

#!/bin/bash

. ./001-helper-functions-library.sh
. ./001-versions.sh

echo $0

# Check for configuration file
if [ ! -f ./busybuntu.conf ]; then
    echo "Configuration file 'busybuntu.conf' not found."
    exit 1
fi

# Parse configuration file to check if cloud-clis feature is enabled
cloud_clis_enabled="false"
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
            if [[ "$key" == "cloud-clis" ]]; then
                cloud_clis_enabled="$value"
            fi
            ;;
    esac
done < busybuntu.conf

# Exit early if cloud-clis is not enabled in configuration
if [[ "$cloud_clis_enabled" != "true" ]]; then
    echo "$0: Cloud CLI installation skipped - not enabled in configuration (features.cloud-clis=false)"
    exit 0
fi

echo "$0: Installing Cloud CLIs as requested in configuration..."

echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

sudo apt update  -y && sudo apt-get install -y google-cloud-cli
# OR brew install --cask google-cloud-sdk

brew install awscli azure-cli
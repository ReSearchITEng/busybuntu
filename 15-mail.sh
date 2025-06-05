#!/bin/bash

. ./001-helper-functions-library.sh
. ./001-versions.sh

echo $0

sudo apt install -y mailutils libsasl2-2 ca-certificates libsasl2-modules

# Check for configuration file
if [ ! -f ./busybuntu.conf ]; then
    echo "Configuration file 'busybuntu.conf' not found."
    exit 1
fi

# Parse configuration file to check if postfix feature is enabled
postfix_enabled="false"
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
            if [[ "$key" == "postfix" ]]; then
                postfix_enabled="$value"
            fi
            ;;
    esac
done < busybuntu.conf

# Exit early if postfix is not enabled in configuration
if [[ "$postfix_enabled" != "true" ]]; then
    echo "$0: Postfix installation skipped - not enabled in configuration (features.postfix=false)"
    exit 0
fi

echo "$0: Installing Postfix as requested in configuration..."
sudo apt install -y postfix
cat <<EOF | sudo tee /etc/postfix/main.cf

relayhost = [smtp.gmail.com]:587
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_sasl_security_options = noanonymous
smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt
smtp_use_tls = yes

EOF

echo ' REPLACE ADDRESS AND EMAIL !!!!!!! '
cat <<EOF
Go to your Google Account settings: https://www.google.com/account/about/.
Select "Security" from the navigation panel.
Under "Signing in to Google," choose "App passwords."
EOF

cat <<'EOF' | sudo tee /etc/postfix/sasl_passwd >/dev/null
[smtp.gmail.com]:587 <your_gmail_address>:<app_password>
EOF

#If modifying main.cf, be sure to run 'systemctl reload postfix'.

sudo chmod 400 /etc/postfix/sasl_passwd
sudo postmap /etc/postfix/sasl_passwd
sudo systemctl reload postfix
sudo systemctl restart postfix
#echo "This is a test email" | mail -s "Test from LOD" <your_gmail_address> <recipient_email>



#!/bin/bash

. ./001-helper-functions-library.sh
. ./001-versions.sh

echo $0

sudo apt update && sudo apt install -y postfix mailutils libsasl2-2 ca-certificates libsasl2-modules
cat <<EOF >/etc/postfix/main.cf

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
sudo systemctl restart postfix
echo "This is a test email" | mail -s "Test from LOD" <your_gmail_address> <recipient_email>



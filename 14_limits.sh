#!/bin/bash

. ./001-helper-functions-library.sh
. ./001-versions.sh

echo $0

set -vx
cat <<EOF | sudo tee /etc/security/limits.d/manual.conf >/dev/null
* soft nofile 20000
* hard nofile 1048500
* soft nproc 62796
* hard nproc 65535
EOF


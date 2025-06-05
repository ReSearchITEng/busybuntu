#!/bin/bash

. ./001-helper-functions-library.sh
. ./001-versions.sh

echo $0

set -vx
cat <<EOF | sudo tee /etc/security/limits.d/manual.conf >/dev/null
* soft nofile 900000
* hard nofile 948500
* soft nproc 300100
* hard nproc 400100
EOF


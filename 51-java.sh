#!/bin/bash

. ./001-helper-functions-library.sh
. ./001-versions.sh

echo $0

sudo apt install -y openjdk-11-jdk # maven
sudo update-java-alternatives --set java-1.11.0-openjdk-amd64
echo "$0: the JAVA_HOME will be following update-alternatives"
cat <<'EOF' | sudo tee /etc/profile.d/java-setup.sh >/dev/null

export JDK_HOME=$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")
export JAVA_HOME=${JDK_HOME}
export JRE_HOME=${JDK_HOME}/jre/

## JAVA_HOME , JDK_HOME, JRE_HOME -> AUTOMATIC!
# They are set automatically, don't do it manually!
# To switch beween java version, this is the correct way: 
# `sudo update-java-alternatives --set java-1.11.0-openjdk-amd64`
# OR:
# `sudo update-java-alternatives --set java-1.8.0-openjdk-amd64`
# and relogin (or source . /etc/profile.d/java-setup.sh)

EOF


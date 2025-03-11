export DEBIAN_FRONTEND=noninteractive

pip_install(){
  wget -q https://raw.githubusercontent.com/ReSearchITEng/aptpip/refs/heads/main/aptpip.py -O /tmp/aptpip.py
  chmod +x /tmp/aptpip.py
  sudo /tmp/aptpip.py install $@
}

install_sw(){
  ## As input, provide the path to the binary to be installed. Its name must be without version.
  ## install_sw ./helm  ,  and NOT install_sw ./helm-v3.4.1
  SW_SRC=$1
  SW_VER=$2 # OPTIONAL
  SW=$(basename "${SW_SRC}")
  if [[ -z "${SW_SRC}" || "$SW" == "$SW_SRC" ]]; then
    echo "please provide as parameter the path to your source binary" && return 1
  fi
  if [[ -z "${SW_VER}" ]]; then
    [[ ! -x $SW_SRC ]] && chmod +x $SW_SRC
    [[ ! -x $SW_SRC ]] && sudo chmod +x $SW_SRC
    VERSION=$($SW_SRC version 2>/dev/null | perl -p -e 's/.*(v[0-9]*\.[0-9]*\.[0-9]*).*/\1/g' | tr -cd '0-9\.v\n' | grep -e '[0-9]' | head -1 )
    if [[ -z "${VERSION}" ]]; then #try --version
      VERSION=$($SW_SRC --version 2>/dev/null | perl -p -e 's/.*(v[0-9]*\.[0-9]*\.[0-9]*).*/\1/g' | tr -cd '0-9\.v\n' | grep -e '[0-9]' | head -1 )
    fi
  else
    VERSION="${SW_VER}"
  fi
  [[ -z "${VERSION}" ]] && echo "$0 : Error - version could not be determined" && return 2
  sudo cp ${SW_SRC} /usr/local/bin/${SW}-${VERSION}
  sudo chmod +x /usr/local/bin/${SW}-${VERSION}

  ver_raw=$(echo $VERSION | tr -cd '0-9\.' | cut -d. -f1)
  ver_raw_prefixed=$(echo "00$ver_raw")
  VERSION_MAJOR=${ver_raw_prefixed:(-3)} # last 3 digits
  ver_raw=$(echo $VERSION | tr -cd '0-9\.' | cut -d. -f2)
  ver_raw_prefixed=$(echo "00$ver_raw")
  VERSION_MINOR=${ver_raw_prefixed:(-3)} # last 3 digits
  ver_raw=$(echo $VERSION | tr -cd '0-9\.' | cut -d. -f3)
  ver_raw_prefixed=$(echo "00$ver_raw")
  VERSION_PATCH=${ver_raw_prefixed:(-3)} # last 3 digits
  PRIORITY="${VERSION_MAJOR}${VERSION_MINOR}${VERSION_PATCH}"
  [[ -x /usr/local/bin/${SW} && ! -L /usr/local/bin/${SW} ]] && sudo mv -f /usr/local/bin/${SW} /usr/local/bin/${SW}.non-link
  sudo update-alternatives --install /usr/local/bin/${SW} ${SW} /usr/local/bin/${SW}-${VERSION} ${PRIORITY}
  sudo update-alternatives --display ${SW}
  echo "To force-change it to a different version manually, RUN: sudo update-alternatives --config ${SW}"
  echo "To set it back to auto (newest version) RUN: sudo update-alternatives --auto ${SW}"
  # update-alternatives --get-selections #to get all sw that uses update-alternatives
}

apt_add_gpg_key(){
  URL_GPG=$1
  GPG_KEY_NAME=$2
  #curl -sLk $URL_GPG | gpg --dearmor -o /usr/share/keyrings/$GPG_KEY_NAME || true
  sudo mv /etc/apt/trusted.gpg.d/$GPG_KEY_NAME /etc/apt/trusted.gpg.d/old.$GPG_KEY_NAME 2>/dev/null || true
  curl -sLk $URL_GPG | gpg --dearmor | sudo gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/$GPG_KEY_NAME --import || true
  sudo chmod 644 /etc/apt/trusted.gpg.d/$GPG_KEY_NAME
}

check() {
  # Function to check config file parameters (simplified version)

  # Input:
  # $1: Section (e.g., global)
  # $2: Parameter (e.g., installationType)
  # $3: Value to check against (e.g., server)

  if [ $# -ne 3 ]; then
    echo "Usage: check <section> <parameter> <value>"
    return 1 # Indicate error - wrong number of arguments
  fi

  local section="$1"
  local parameter="$2"
  local expected_value="$3"

  if [ -z "$section" ] || [ -z "$parameter" ]; then
    echo "Error: Invalid section or parameter provided."
    return 1 # Indicate error - invalid format
  fi

  # Check if config.conf file exists
  if [ ! -f "config.conf" ]; then
    echo "Error: config.conf file not found."
    return 1 # Indicate error - config file missing
  fi

  # Find the section in the config file
  section_start=$(grep -n "^\[${section}\]$" config.conf | cut -d':' -f1)

  if [ -z "$section_start" ]; then
    # Section not found
    return 1 # Return false (non-zero exit code)
  fi

  # Find the parameter within the section
  config_value=$(
    sed -n "${section_start},\$p" config.conf | # From section start line to end of file
    sed -e "1d" | # Delete the section header line itself
    sed -e '/^\[.*\]/,$d' | # Delete from the next section header to the end
    grep "^${parameter}=" | # Find the parameter line
    cut -d'=' -f2 |    # Extract the value after '='
    head -n 1           # Take the first match
  )

  # Remove leading/trailing whitespace from config_value
  config_value=$(echo -e "$config_value")

  if [ -n "$config_value" ] && [ "$config_value" == "$expected_value" ]; then
    return 0 # Return true (zero exit code)
  else
    return 1 # Return false (non-zero exit code)
  fi
}
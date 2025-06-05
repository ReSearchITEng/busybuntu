## 001-versions.sh
export  KREW_VERSION=${KREW_VERSION:-"0.4.1"} # https://github.com/kubernetes-sigs/krew/releases/download/v${KREW_VERSION}/krew.{tar.gz,yaml}
export  KUBEVAL_VERSION=${KUBEVAL_VERSION:-"0.15.0"} # https://github.com/instrumenta/kubeval/releases/download/${KUBEVAL_VERSION}/kubeval-linux-amd64.tar.gz
export  KTAIL_VERSION=${KTAIL_VERSION:-"1.0.1"} # https://github.com/atombender/ktail/releases/download/v${KTAIL_VERSION}/ktail-linux-amd64
export  KUBEBOX_VERSION=${KUBEBOX_VERSION:-"0.9.0"} # https://github.com/astefanutti/kubebox/releases/download/v${KUBEBOX_VERSION}/kubebox-linux
export  LENS_VERSION=${LENS_VERSION:-"4.1.2"} # https://github.com/lensapp/lens/releases/download/v${LENS_VERSION}/Lens-${LENS_VERSION}.AppImage
export  OCTANT_VERSION=${OCTANT_VERSION:-"0.17.0"} # https://github.com/vmware-tanzu/octant/releases/download/v${OCTANT_VERSION}/octant_${OCTANT_VERSION}_Linux-64bit.deb
export  XRDP_INSTALLER_VERSION=${XRDP_INSTALLER_VERSION:-"1.3"} # http://www.c-nergy.be/downloads/xrdp-installer-${XRDP_INSTALLER_VERSION}.zip http://www.c-nergy.be/products.html
export  APTPIP_VERSION=${APTPIP_VERSION:-"$(date +%Y%m%d)"} # https://raw.githubusercontent.com/ReSearchITEng/aptpip/refs/heads/main/aptpip.py


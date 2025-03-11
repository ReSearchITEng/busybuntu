## 001-versions.sh
export  #TERRAFORM_VERSION -> latest will be taken always automatically
export  TERRAGRUNT_VERSION=${TERRAGRUNT_VERSION:-"0.26.7"} # https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64
export  #AWS_CLI_VERSION -> latest will be taken always automatically
export  AWS_IAM_AUTH_VERSION=${AWS_IAM_AUTH_VERSION:-"1.19.6/2021-01-05"}
export  KREW_VERSION=${KREW_VERSION:-"0.4.1"} # https://github.com/kubernetes-sigs/krew/releases/download/v${KREW_VERSION}/krew.{tar.gz,yaml}
export  KUBEVAL_VERSION=${KUBEVAL_VERSION:-"0.15.0"} # https://github.com/instrumenta/kubeval/releases/download/${KUBEVAL_VERSION}/kubeval-linux-amd64.tar.gz
export  KTAIL_VERSION=${KTAIL_VERSION:-"1.0.1"} # https://github.com/atombender/ktail/releases/download/v${KTAIL_VERSION}/ktail-linux-amd64
export  K9S_VERSION=${K9S_VERSION:-"0.24.2"} # https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_x86_64.tar.gz
export  KUBEBOX_VERSION=${KUBEBOX_VERSION:-"0.9.0"} # https://github.com/astefanutti/kubebox/releases/download/v${KUBEBOX_VERSION}/kubebox-linux
export  LENS_VERSION=${LENS_VERSION:-"4.1.2"} # https://github.com/lensapp/lens/releases/download/v${LENS_VERSION}/Lens-${LENS_VERSION}.AppImage
export  OCTANT_VERSION=${OCTANT_VERSION:-"0.17.0"} # https://github.com/vmware-tanzu/octant/releases/download/v${OCTANT_VERSION}/octant_${OCTANT_VERSION}_Linux-64bit.deb
export  HELM_VERSION_3=${HELM_VERSION_3:-"3.7.0"} # https://github.com/helm/helm/releases https://get.helm.sh/helm-v3.5.2-linux-amd64.tar.gz
export  STARSHIP_VERSION=${STARSHIP_VERSION:-"1.1.1"} # https://github.com/starship/starship/releases
export  WEASEL_PAGEANT_VERSION=${WEASEL_PAGEANT_VERSION:-"1.4"} # https://github.com/vuori/weasel-pageant/releases
export  EXA_VERSION=${EXA_VERSION:-"0.9.0"} # https://github.com/ogham/exa/releases/download/v${EXA_VERSION}/exa-linux-x86_64-${EXA_VERSION}.zip
export  KIND_VERSION=${KIND_VERSION:-"0.10.0"} # https://github.com/kubernetes-sigs/kind/releases/download/v${KIND_VERSION}/kind-linux-amd64
export  KUBEADM_PLAYBOOK_VERSION=${KUBEADM_PLAYBOOK_VERSION:-"1.21"} # https://github.com/ReSearchITEng/kubeadm-playbook/archive/v${KUBEADM_PLAYBOOK_VERSION}.tar.gz
export  XRDP_INSTALLER_VERSION=${XRDP_INSTALLER_VERSION:-"1.3"} # http://www.c-nergy.be/downloads/xrdp-installer-${XRDP_INSTALLER_VERSION}.zip http://www.c-nergy.be/products.html


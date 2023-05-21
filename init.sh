#!/bin/sh

# TODO LIST:
# - Fix arguements
# - Handle kubeadm args better
# - Finish and test update_cluster function

KUBE_VERSION="${KUBE_VERSION:=1.26}"
HOSTNAME="${HOSTNAME:=worker}"
CIDR="${CIDR:=10.244.0.0/16}"
# IGNORE_PREFLIGHT_ERRORS=

help() {
  printf "some help"
}

update() {
# Update Linux Kernel and APK library to the latest-stable version
  cat <<'EOT' >> /etc/apk/repositories
http://dl-cdn.alpinelinux.org/alpine/latest-stable/main
http://dl-cdn.alpinelinux.org/alpine/latest-stable/community
http://dl-cdn.alpinelinux.org/alpine/edge/community
http://dl-cdn.alpinelinux.org/alpine/edge/testing
EOT

  apk update && apk upgrade
  apk update --available
  apk upgrade --available
}

upgrade() {
  # Install util packages
  apk add uuidgen \
          nfs-utils \
          cni-plugins \
          cni-plugin-flannel \
          flannel-contrib-cni \
          flannel

  # Install Kubernetes packages
  apk add kubelet \
          kubeadm \
          kubectl \
          containerd

  # Add kernel module for networking
  echo "br_netfilter" > /etc/modules-load.d/k8s.conf
  modprobe br_netfilter
  echo 1 > /proc/sys/net/ipv4/ip_forward

  # Remove swap storage
  cat /etc/fstab | grep -v swap > temp.fstab
  cat temp.fstab > /etc/fstab
  rm temp.fstab
  swapoff -a

  # Fix id error messages
  uuidgen > /etc/machine-id

  # Add services
  rc-update add containerd
  rc-update add kubelet
  rc-update add ntpd

  # Start services
  /etc/init.d/ntpd start
  /etc/init.d/containerd start

  # Create flannel Symlink
  ln -s /usr/libexec/cni/flannel-amd64 /usr/libexec/cni/flannel

  # Ensure that brigeded packets traverse iptable rules
  echo "net.bridge.bridge-nf-call-iptables=1" >> /etc/sysctl.conf
  sysctl net.bridge.bridge-nf-call-iptables=1

  # Pin your versions!  If you update and the nodes get out of sync, it implodes.
  # NOTE: In the future you will manually have to add a newer version the same way to upgrade.
  # ------------------------------------------------------------------------------------------
  # apk add 'kubelet=~1.26'
  # apk add 'kubeadm=~1.26'
  # apk add 'kubectl=~1.26'

  apk add kubelet=~${KUBE_VERSION}
  apk add kubeadm=~${KUBE_VERSION}
  apk add kubectl=~${KUBE_VERSION}

  # Setup default hostname
  hostname ${HOSTNAME}
  echo ${HOSTNAME} > /etc/hostname

  # Setup default kubeconfig
  mkdir ~/.kube > /dev/null 2>&1
  ln -s /etc/kubernetes/kubelet.conf /root/.kube/config > /dev/null 2>&1

  # Pre-pulling kubernetes images
  kubeadm config images pull
}

restart() {
  # Countdown for reboot to use new Linux Kernel version
  replace="\033[1A\033[K"
  reboot_countdown="5"

  for i in $(seq ${reboot_countdown} -1 1)
  do 
      echo "Updating Kernel. Rebooting in $i."
      sleep 0.5
      echo -e "${replace}Updating Kernel. Rebooting in $i.."
      sleep 0.5
  done
  sync
  reboot
}

generate_cluster() {
  # Set hostname
  hostname ${HOSTNAME}
  echo ${HOSTNAME} > /etc/hostname

  # Create master node and subnet
  kubeadm init --pod-network-cidr=${CIDR} --node-name=$(hostname) $IGNORE_PREFLIGHT_ERRORS

  # Symlink Kubectl config 
  mkdir ~/.kube > /dev/null 2>&1
  rm /root/.kube/config
  ln -s /etc/kubernetes/admin.conf /root/.kube/config

  # Set up CNI (flannel)
  kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

  # Generate worker node join command
  kubeadm token create --print-join-command
}

destroy_cluster() {
  printf "y" | kubeadm reset
}

update_cluster() {
  # Pin your versions!  If you update and the nodes get out of sync, it implodes.
  # NOTE: In the future you will manually have to add a newer version the same way to upgrade.
  # ------------------------------------------------------------------------------------------
  # apk add 'kubelet=~1.26'
  # apk add 'kubeadm=~1.26'
  # apk add 'kubectl=~1.26'

  apk add kubelet=~${KUBE_VERSION}
  apk add kubeadm=~${KUBE_VERSION}
  apk add kubectl=~${KUBE_VERSION}

  kubeadm upgrade
}

# From this point down is just script logic
init_logic() {
  while [ $# -gt 0 ]
  do
    arg="$1"
    shift;
    case "${arg}" in
      "--hostname" )   
      HOSTNAME="$1";shift; 
      ;; 
      "--kube-version" )   
      KUBE_VERSION="$1";shift; 
      ;;
      *) help
    esac
  done
  # copy this script to sh so you can use it as a global alpine & k8 cluster controller
  cp ./init.sh /bin/kubecon
  chmod +x /bin/kubecon

  update
  upgrade
  restart
}

generate_cluster_logic() {
  while [ $# -gt 0 ]
  do
    arg="$1"
    shift;
    case "${arg}" in
      "--ignore-preflight-errors" )
      IGNORE_PREFLIGHT_ERRORS="--ignore-preflight-errors=all";;
      "--hostname" )   
      HOSTNAME="$1";shift; 
      ;; 
      "--cidr" )
      CIDR="$1"; shift; 
      ;;
      *) help
    esac
  done
  generate_cluster
}

opt="$1"; 
shift;

case "${opt}" in
  "update-kernel" ) update; restart;
      ;;
  "init" ) init_logic
      ;; 
  "generate-cluster" ) generate_cluster_logic
      ;;
  "destroy-cluster" ) destroy_cluster
      ;;
  *) help
esac
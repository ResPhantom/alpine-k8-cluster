# What is this project all about?

In essence this project is used to make it easier to set up a kubernetes cluster on Alpine Linux. 

'Why use Alpine?', you ask. Alpine is a linux distro that focuses on 2 things, security and distro size. By having a smaller distro, you tend to have a lot less packages and libraries installed. This means there is a less likelyhood that one of them have an unknown exploitable vulnerability. 

Also by making use of a lightweight OS, you have more resources dedicated to running your apps. Less is more.

# Furture prospects

I would like to find a suitable method to use the minirootfs version of Alpine instead of the the standard Alpine ISO, because the minirootfs is around 3.5MB and standard Alpine ISO is roughly 200MB. The only thing missing for the minirootfs is a boot functionality. 

I want to find a way to build an compact ISO alpine image that is built around using Kubernetes in a secure datacenter environment. This would include seamless and simple kernel updates, quick cluster setup and the capabilities to monitor your physical machines. 

Such as your Network packets, latency, CPU usage, RAM, storage and various other common useful statistics. Unfortunately, for now we'll have to settle with humble beginnings, which is a script that needs a little bit of work.

# Alpine releases

Alpine Download Page: [ https://www.alpinelinux.org/downloads/ ]

I reccomend the [standard x86_64] version, even though it might be an old version the `init.sh` script will update to the latest stable version.

# Install alpine
Localhost login: `root` \
Run `setup-alpine`

## Example of Alpine setup

Select keyboard layout [none]: `us` \
Select variant (or 'aboort'): `us` \
Enter system hostname [localhost]: `ENTER` \
Available interfaces are: eth0 eth1 \
Which one do you want to initialize? [eth0]: `ENTER` \
Ip address for eth0? [dhcp]: `ENTER` \
Do you want any manual network configuration? (y/n) [n]: `ENTER` \
New Password: `root` \
Retype Password: `root` \
Which Timezone are you in? ('?' for list) [UTC]: `Europe/Berlin` \
HTTP/FTP proxy URL? [none]: `ENTER` \
Which NTP client to run? ('busybox','openntpd','chrony' or 'none') [chrony]: `busybox` \
Press `q` \
Enter mirror number (1-72) or URL to add (or r/f/e/done) [1]: `r` \
Setup a user? (enter a lower-case loginname, or 'no') [no]: `ENTER` \
Which server? ('openssh','dropbear', or none) [openssh]: `ENTER` \
Allow root ssh login? ('?' for help) [phrohibit-password]: `ENTER` \
Enter ssh key or URL for root (or 'none') [none]: `ENTER` \
Available disks are: sda \
Which disks would you like to use? [none]: `sda` \
How would you like to use it? ('sys', 'data', 'crypt', 'lvm' or '?') [?]: `sys` \
WARNING: Erase above disk(s) and continue? (y/n) [n]: `y` 

NOTE: Don't forget to unmount/remove the iso and reboot.
```sh
reboot
```

## Download Kubernetes setup script
Unfortunately to get the `init.sh` script you have to type out one of 2 options: \
Option 1: Download the raw file
```sh
wget https://raw.githubusercontent.com/resphantom/alpine-k8/master/init.sh
```
Option 2: Install git and clone the repository
```sh
apk add git
git clone https://github.com/resphantom/alpine-k8.git
cd alpine-k8-cluster
```
Install `bash` and give the `init.sh` permission to execute
```sh
chmod +x init.sh
```

## Install Kubernetes
Note: This script has to be run for both master and worker nodes
You can set the kubernetes version manually by setting the `KUBE_VERSION` variable
```sh
export KUBE_VERSION=1.27
```
Run the folloing command
Note: `init.sh` will copy and rename itself to `/bin/kubecom`
```sh
./init.sh init
```

## Register master node

### Automated method
```sh
kubecom generate-cluster
```

### Manual method
Update hostname
```sh
hostname master-1
echo "master-1" > /etc/hostname
```
NOTE: In the following command you can add the `--ignore-preflight-errors=all` flag to bypass preflight checks for machines with less than recommended resources, however the Kubernetes cluster might not fully install correctly. 

Recommended resources are `2 CPU` and `2 GB RAM`

Initialise Kubernetes cluster master node. 
```sh
kubeadm init --pod-network-cidr=10.244.0.0/16 --node-name=$(hostname)
```
Setup Kubernetes cli config by replacing existing config with a symlink to the admin config
```sh
rm /root/.kube/config || mkdir ~/.kube
ln -s /etc/kubernetes/admin.conf /root/.kube/config
```
Install a CNI controller, we can use flannel for simplicity
```sh
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
```
You should now be able to use the custom join command in the other kuernetes machine setup by generating the join command
```sh
kubeadm token create --print-join-command
```

### Confirm setup
```sh
kubectl get all -n kube-system
```

## Register worker node
On a master node run the following join command
```sh
kubeadm token create --print-join-command
```
Update hostname
```sh
hostname worker-1
echo "worker-1" > /etc/hostname
```
Copy over the uniquely generated command from the master node into 'join.sh', example of a kubernetes join command below:
```sh
kubeadm join 10.0.0.150:6443 --token xunjoc.yx2m65r8inhxph9i --discovery-token-ca-cert-hash sha256:e38dd277fe1143771dfe17261d9862e5313d1cdf3922ea86f8f73b6c0a515798
```

[//]: # (SOME USEFUL LINKS )
[standard x86_64]: https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/x86_64/alpine-standard-3.18.0-x86_64.iso

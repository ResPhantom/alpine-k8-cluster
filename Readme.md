# Alpine releases

Download link: `https://www.alpinelinux.org/downloads/`

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
Press `q` + `ENTER` \
Enter mirror number (1-72) or URL to add (or r/f/e/done) [1]: `r` \
Setup a user? (enter a lower-case loginname, or 'no') [no]: `ENTER` \
Which server? ('openssh','dropbear', or none) [openssh]: `ENTER` \
Allow root ssh login? ('?' for help) [phrohibit-password]: `ENTER` \
Enter ssh key or URL for root (or 'none') [none]: `ENTER` \
Available disks are: sda \
Which disks would you like to use? [none]: `sda` \
How would you like to use it? ('sys', 'data', 'crypt', 'lvm' or '?') [?]: `sys` \
WARNING: Erase above disk(s) and continue? (y/n) [n]: `y` 

## Mount shared folder
"vbox_shared" is the name of the shared folder
```sh
mkdir -p /mnt/shared; modprobe -a vboxsf; mount -t vboxsf vbox_shared /mnt/shared
```

## Install Kubernetes
You can set the kubernetes version manually by setting the `KUBE_VERSION` variable
```sh
export KUBE_VERSION=1.27
```
Run the folloing command
```sh
./init.sh
```

## Register Master Node
Update hostname
```sh
hostname master-1
echo "master-1" > /etc/hostname
```
Initialise Kubernetes master node, bypass preflight checks for small virtual machines
```sh
kubeadm init --pod-network-cidr=10.244.0.0/16 --node-name=$(hostname) --ignore-preflight-errors=all
```
Setup Kubernetes cli config by replacing existing config with a symlink to the admin account
```sh
mkdir ~/.kube
rm /root/.kube/config
ln -s /etc/kubernetes/admin.conf /root/.kube/config
```
Install a CNI controller, using flannel for simplicity
```sh
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
```
You should now be able to use the custom join command in the other VM by generating the join command
```sh
kubeadm token create --print-join-command
```

## Register Worker Node
Update hostname
```sh
hostname worker-1
echo "worker-1" > /etc/hostname
```
Copy over the uniquely generated command from master logs into 'join.sh', example of the command below:
```sh
kubeadm join 10.0.0.150:6443 --token xunjoc.yx2m65r8inhxph9i --discovery-token-ca-cert-hash sha256:e38dd277fe1143771dfe17261d9862e5313d1cdf3922ea86f8f73b6c0a515798
```

# Alpine releases

Download link: `https://www.alpinelinux.org/downloads/`

# Install alpine
Localhost login: `root`
Run `setup-alpine`

## Example of Alpine setup

Select keyboard layout [none]: `us`
Select variant (or 'aboort'): `us`

Enter system hostname [localhost]: Press Enter

Available interfaces are: eth0 eth1
Which one do you want to initialize? [eth0]: Press Enter
Ip address for eth0? [dhcp]: Press Enter
Do you want any manual network configuration? (y/n) [n]: Press Enter

New Password: `root`
Retype Password: `root`

Which Timezone are you in? ('?' for list) [UTC]: `Europe/Berlin`

HTTP/FTP proxy URL? [none]: Press Enter
Which NTP client to run? ('busybox','openntpd','chrony' or 'none') [chrony]: `busybox`

press `q`
-### Note: r = random
Enter mirror number (1-72) or URL to add (or r/f/e/done) [1]: `r`

Setup a user? (enter a lower-case loginname, or 'no') [no]: Press Enter
Which server? ('openssh','dropbear', or none) [openssh]: Press Enter
Allow root ssh login? ('?' for help) [phrohibit-password]: Press Enter
Enter ssh key or URL for root (or 'none') [none]: Press Enter

Available disks are: sda
Which disks would you like to use? [none]: `sda`
How would you like to use it? ('sys', 'data', 'crypt', 'lvm' or '?') [?]: `sys`
WARNING: Erase above disk(s) and continue? (y/n) [n]: `y`

## Mount shared folder
"vbox_shared" is the name of the shared folder
`mkdir -p /mnt/shared; modprobe -a vboxsf; mount -t vboxsf vbox_shared /mnt/shared`

## Install Kubernetes
Run the folloing command
/mnt/shared/init.sh

## Register Master Node
Update hostname
`hostname master-1` \
`echo "master-1" > /etc/hostname` \
Get exact kubernetes version
`kubeadm version` \
Get IP address
`ifconfig` \
Initialise Kubernetes master node, bypass preflight checks for small virtual machines
`kubeadm init --apiserver-advertise-address=<Master Node IP Here> --kubernetes version=1.26.1 --ignore-preflight-errors=all | tee /mnt/shared/logs` \
You should now be able to use the custom join command in the other VM

## Register Worker Node
Update hostname
`hostname worker-1` \
`echo "worker-1" > /etc/hostname` \
Copy over the uniquely generated command from master logs into 'join.sh', example of the command below:
`kubeadm join 10.0.0.150:6443 --token xunjoc.yx2m65r8inhxph9i --discovery-token-ca-cert-hash sha256:e38dd277fe1143771dfe17261d9862e5313d1cdf3922ea86f8f73b6c0a515798`

{

sudo cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
sudo cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

sudo lsmod | grep br_netfilter
sudo lsmod | grep overlay

# verify being set to 1
sudo sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-iptables net.ipv4.ip_forward



### install containerd

sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
# Add the repository to Apt sources:
sudo echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update


sudo apt-get install -y containerd.io

#Customizing containerd
#containerd uses a configuration file located in /etc/containerd/config.toml for specifying daemon level options. A sample configuration file can be found here.

# when running this with sudo it still gives you permission denied error. So the best thing to do is doing it manually, sudo -i and then run "containerd config default > /etc/containerd/config.toml"
#The default configuration can be generated via containerd config default > /etc/containerd/config.toml.
#and then do vi and change SystemdCgroup = false to true, also change pause:3.6 to 3.9
config_file="/etc/containerd/config.toml"

##for changes to take affect
sudo systemctl restart containerd

# then we should do cni config
#Step 3: Installing CNI plugins
# this is the page to follow, scroll directly to the STEP 3... --> https://github.com/containerd/containerd/blob/main/docs/getting-started.md  
#Download the cni-plugins-<OS>-<ARCH>-<VERSION>.tgz archive from https://github.com/containernetworking/plugins/releases , verify its sha256sum, and extract it under /opt/cni/bin:
#cni-plugins-linux-amd64-v1.4.0.tgz was safe to install!
$ sudo mkdir -p /opt/cni/bin
$ sudo tar Cxzvf /opt/cni/bin /home/vagrant/cni-plugins-linux-amd64-v1.4.0.tgz


#These instructions are for Kubernetes 1.29.
#Update the apt package index and install packages needed to use the Kubernetes apt repository:
sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

#Download the public signing key for the Kubernetes package repositories. The same signing key is used for all repositories so you can disregard the version in the URL
sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

#Add the appropriate Kubernetes apt repository. Please note that this repository have packages only for Kubernetes 1.29; for other Kubernetes minor versions, you need to change the Kubernetes minor version in the URL to match your desired minor version (you should also check that you are reading the documentation for the version of Kubernetes that you plan to install)
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
sudo echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl


# since we created another interface enp0s8 here, we should add a route for the pod network to use this interface #
sudo apt install net-tools
sleep 10
sudo ip route add 10.244.0.0/16 via 192.168.56.1 dev enp0s8

## optional section ##
#Container Runtime Interface (CRI) CLI
# crictl provides a CLI for CRI-compatible container runtimes. This allows the CRI runtime developers to debug their runtime without needing to set up Kubernetes components.(still beta)
# here is the releases page, always get the latest release --> https://github.com/kubernetes-sigs/cri-tools/releases 
#VERSION="v1.29.0" # check latest version in /releases page
#wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz
#sudo tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
#rm -f crictl-$VERSION-linux-amd64.tar.gz

#crictl config \
#    --set runtime-endpoint=unix:///run/containerd/containerd.sock \
#    --set image-endpoint=unix:///run/containerd/containerd.sock

#cat <<EOF > /etc/default/kubelet
#KUBELET_EXTRA_ARGS='--node-ip $(ip -4 addr show enp0s8 | grep "inet" | head -1 |awk '{print $2}' | cut -d/ -f1)'
#EOF
}

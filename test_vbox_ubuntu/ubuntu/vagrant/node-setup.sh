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

sudo cat <<EOF | sudo tee /etc/containerd/config.toml
version = 2
# The 'plugins."io.containerd.grpc.v1.cri"' table contains all of the server options.
[plugins."io.containerd.grpc.v1.cri"]
  stream_server_address = "127.0.0.1"
  stream_server_port = "0"
  stream_idle_timeout = "4h"
  enable_selinux = false
# sandbox_image is the image used by sandbox container.
  sandbox_image = "registry.k8s.io/pause:3.9"
# 'plugins."io.containerd.grpc.v1.cri".containerd' contains config related to containerd
  [plugins."io.containerd.grpc.v1.cri".containerd]
    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
      cni_conf_dir = "/etc/cni/net.d"
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
        SystemdCgroup = true
EOF
#for changes to take affect
sudo systemctl restart containerd







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

#crictl config \
#    --set runtime-endpoint=unix:///run/containerd/containerd.sock \
#    --set image-endpoint=unix:///run/containerd/containerd.sock

#cat <<EOF > /etc/default/kubelet
#KUBELET_EXTRA_ARGS='--node-ip $(ip -4 addr show enp0s8 | grep "inet" | head -1 |awk '{print $2}' | cut -d/ -f1)'
#EOF
}


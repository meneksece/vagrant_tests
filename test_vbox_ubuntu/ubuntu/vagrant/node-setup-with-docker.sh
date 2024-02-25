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

### install docker, ubuntu/jammy64 is definitely compatible, keep in mind that if you're gonna use docker you must set up cri-dockerd adapter as well
sudo apt-get update

#Run the following command to uninstall all conflicting packages:
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Set up Docker's apt repository.
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

#To install the latest version, run:
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

#verify the installation
sudo docker run hello-world

# check the cgroup driver if it uses systemd
ps -p 1

# check the cgroup driver and version for docker if it uses systemd
sudo docker info 

#to set up crio-dockerd adapter --> https://github.com/Mirantis/cri-dockerd  (This adapter provides a shim  for Docker Engine that lets you control Docker via the Kubernetes Container Runtime Interface.)




docker --version

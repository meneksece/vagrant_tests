{
IFNAME="enp0s8"
POD_CIDR=10.244.0.0/16
SERVICE_CIDR=10.96.0.0/16
INTERNAL_IP="$(ip -4 addr show "enp0s8" | grep "inet" | head -3 |awk '{print $2}' | cut -d/ -f1)"
echo "$POD_CIDR   $SERVICE_CIDR     $INTERNAL_IP"


#sudo kubeadm init --pod-network-cidr $POD_CIDR --service-cidr $SERVICE_CIDR --apiserver-advertise-address $INTERNAL_IP

sleep 20

sudo mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

sudo kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

#kubectl --kubeconfig /etc/kubernetes/admin.conf \
#    apply -f "https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s-1.11.yaml"
}

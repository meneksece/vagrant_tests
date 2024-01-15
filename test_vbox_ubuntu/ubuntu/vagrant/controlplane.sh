{
IFNAME="enp0s8"
POD_CIDR=192.168.0.0/16
SERVICE_CIDR=10.96.0.0/16
INTERNAL_IP="$(ip -4 addr show "enp0s8" | grep "inet" | head -3 |awk '{print $2}' | cut -d/ -f1)"
echo "$POD_CIDR   $SERVICE_CIDR     $INTERNAL_IP"


#sudo kubeadm init --pod-network-cidr $POD_CIDR --service-cidr $SERVICE_CIDR --apiserver-advertise-address $INTERNAL_IP

sleep 20

sudo mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

### https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart   --> followed this document
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/tigera-operator.yaml

# Before creating this manifest, read its contents and make sure its settings are correct for your environment. For example, you may need to change the default IP pool CIDR to match your pod network CIDR.
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/custom-resources.yaml

#Confirm that all of the pods are running with the following command.
watch kubectl get pods -n calico-system

#Remove the taints on the control plane so that you can schedule pods on it.
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
kubectl taint nodes --all node-role.kubernetes.io/master-

#Confirm that you now have a node in your cluster with the following command.
kubectl get nodes -o wide

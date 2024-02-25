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

#confirm that all of the pods are running with the following command. Wait until each pod has the STATUS of Running.
watch kubectl get pods -n calico-system

#Remove the taints on the control plane so that you can schedule pods on it.
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
kubectl taint nodes --all node-role.kubernetes.io/master-

#Confirm that you now have a node in your cluster with the following command.
kubectl get nodes -o wide

# after configuring calico it is normal to see the new routes like below
vagrant@kubemaster:~$ route

#Kernel IP routing table
#Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
#default         _gateway        0.0.0.0         UG    100    0        0 enp0s3
#10.0.2.0        0.0.0.0         255.255.255.0   U     100    0        0 enp0s3
#_gateway        0.0.0.0         255.255.255.255 UH    100    0        0 enp0s3
#10.0.2.3        0.0.0.0         255.255.255.255 UH    100    0        0 enp0s3
#10.244.0.0      192.168.56.1    255.255.0.0     UG    0      0        0 enp0s8
#10.244.141.0    0.0.0.0         255.255.255.192 U     0      0        0 *
#10.244.141.1    0.0.0.0         255.255.255.255 UH    0      0        0 calidee7e659285
#10.244.141.2    0.0.0.0         255.255.255.255 UH    0      0        0 cali855cd1a2694
#10.244.141.3    0.0.0.0         255.255.255.255 UH    0      0        0 cali08f4728e7fb
#10.244.141.4    0.0.0.0         255.255.255.255 UH    0      0        0 cali7e39a5f6b61
#10.244.141.5    0.0.0.0         255.255.255.255 UH    0      0        0 calid0581fb837a
#10.244.141.6    0.0.0.0         255.255.255.255 UH    0      0        0 calif619aa1f87c
#192.168.56.0    0.0.0.0         255.255.255.0   U     0      0        0 enp0s8

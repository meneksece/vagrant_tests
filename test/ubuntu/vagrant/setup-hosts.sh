#!/bin/bash
#
# Set up /etc/hosts so we can resolve all the machines in the VirtualBox network
set -ex
IFNAME="$(ip a | egrep "eth|ens|enp" | head -1 |awk '{print $2}' | cut -d ":" -f1)"
echo "ifname=${IFNAME}"
THISHOST=$2
ADDRESS="$(ip -4 addr show $IFNAME | grep "inet" | head -1 |awk '{print $2}' | cut -d/ -f1)"
NETWORK=$(echo $ADDRESS | awk 'BEGIN {FS="."} ; { printf("%s.%s.%s", $1, $2, $3) }')
sed -e "s/^.*${HOSTNAME}.*/${ADDRESS} ${HOSTNAME} ${HOSTNAME}.local/" -i /etc/hosts

# remove ubuntu-precice entry
sed -e '/^.*ubuntu-precise.*/d' -i /etc/hosts
sed -e "/^.*$2.*/d" -i /etc/hosts

# Update /etc/hosts about other hosts
cat >> /etc/hosts <<EOF
${NETWORK}.11  kubemaster
${NETWORK}.21  kubenode01
${NETWORK}.22  kubenode02
EOF

# Expoert internal IP as an environment variable
echo "INTERNAL_IP=${ADDRESS}" >> /etc/environment

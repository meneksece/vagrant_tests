#!/bin/bash

# Enable password auth in sshd so we can use ssh-copy-id
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
#
# for some distros
systemctl restart sshd
#service ssh restart

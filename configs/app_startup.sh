#! /bin/sh

#configuring UFW/iptables to deny all and only allow from bastion
ufw enable
ufw default deny incoming
ufw default allow outgoing
ufw allow from 172.21.10.10 to any port 2223 proto tcp
ufw reload

# starting the SSHD service
/usr/sbin/sshd -D -e
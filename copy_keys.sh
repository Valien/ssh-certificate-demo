#!/bin/bash

# create the ssh folder to store the downloaded certifcates
echo "Creating ssh_files directory under /tmp"
mkdir /tmp/ssh_files
cd /tmp/ssh_files/ || exit

touch config

echo "Copying certs down from the bastion node..."
docker cp bastion:/etc/ssh/bastion-user-key /tmp/ssh_files/
docker cp bastion:/etc/ssh/bastion-user-key-cert.pub /tmp/ssh_files/

echo "Copying certs from app node..."
docker cp app:/etc/ssh/app-user-key /tmp/ssh_files/
docker cp app:/etc/ssh/app-user-key-cert.pub /tmp/ssh_files/

echo "Copying CA pub keys down..."
docker cp app:/etc/ssh/app_host_ca.pub /tmp/ssh_files/
docker cp bastion:/etc/ssh/bastion_host_ca.pub /tmp/ssh_files/
echo "adding ca.pub to your ssh_known_hosts..."
echo "@cert-authority localhost $(cat /tmp/ssh_files/bastion_host_ca.pub)" >> ~/.ssh/known_hosts
echo "@cert-authority app-node $(cat /tmp/ssh_files/app_host_ca.pub)" >> ~/.ssh/known_hosts

echo "All files have been copied!"
echo "Now copying needed ssh config into /tmp/ssh_files/config"
#sleep 5s

cat >>config<<EOF
Host bastion-node
  HostName localhost
  Port 2222
  User bastion
  IdentityFile /tmp/ssh_files/bastion-user-key
  ProxyJump none

Host app-node
  HostName app-node
  Port 2223
  User appuser
  IdentityFile /tmp/ssh_files/app-user-key
  ProxyJump bastion-node
EOF
#!/bin/bash

# create the ssh folder to store the downloaded certifcates

echo "Creating ssh_files directory under /tmp"
mkdir /tmp/ssh_files
cd /tmp/ssh_files/

echo "Copying certs down from the bastion node..."
docker cp docker-bastion_bastion-node_1:/bastion_ssh/bastion .
docker cp docker-bastion_bastion-node_1:/bastion_ssh/bastion-cert.pub .

# copy ssh files from app to bastion
echo "Copying certs from app node..."
docker cp docker-bastion_app-node_1:/app_ssh/appuser .
docker cp docker-bastion_app-node_1:/app_ssh/appuser-cert.pub .

echo "Copying certs to bastion from ssh_files directory..."
docker cp appuser docker-bastion_bastion-node_1:/bastion_ssh
docker cp appuser-cert.pub docker-bastion_bastion-node_1:/bastion_ssh

echo "All files have been copied!"
echo "Now copying needed ssh config in your /.ssh/config"
sleep 5s

# note: if you have run this already and run it again it will keep appending the
# following to your config file. 
cat >>~/.ssh/config<<EOF

Host bastion-node
  HostName localhost
  Port 2222
  User bastion
  IdentityFile /tmp/ssh_files/bastion

Host app-node
  HostName app-node
  Port 2223
  User appuser
  IdentityFile /tmp/ssh_files/appuser
  ProxyJump bastion-node
EOF

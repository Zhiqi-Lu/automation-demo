#!/bin/bash

# add docker repo to apt and install docker
mkdir -p /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# add nexus docker registry address
cat > /etc/docker/daemon.json<<EOF
{
        "registry-mirrors" : ["http://10.0.100.30:8200", "http://10.0.100.30:8200"],
        "insecure-registries" : ["10.0.100.30:8200", "10.0.100.30:8300"]
}
EOF


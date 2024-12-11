#!/bin/bash

#Instalar Docker e Docker compose

sudo apt update
sudo apt install -y docker.io
sudo systemctl start docker
sudo usermod -aG docker $(whoami)
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

#Criar docker-compose.yaml

mkdir ~/dc && cd ~/dc

cat << EOF > docker-compose.yaml
version: '3'

services:
  wordpress:
    image: wordpress:latest
    restart: always
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: <RDS Endpoint>
      WORDPRESS_DB_USER: <user>
      WORDPRESS_DB_PASSWORD: <password>
      WORDPRESS_DB_NAME: <database name>
    volumes:
      - /efs/wordpress:/var/www/html

EOF

#EFS

sudo mkdir -p /efs
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y nfs-common
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-094e853ccac82872b.efs.us-east-1.amazonaws.com:/ /efs
echo "fs-094e853ccac82872b.efs.us-east-1.amazonaws.com:/ /efs nfs4 defaults,_netdev 0 0" | sudo tee -a /etc/fstab


#Montar Wordpress via Docker Compose

docker-compose up -d


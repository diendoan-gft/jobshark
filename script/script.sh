#!/bin/bash
sudo apt update -y
sudo apt install nginx -y
sudo systemctl enable nginx
sudo snap install amazon-ssm-agent --classic -y
sudo snap start amazon-ssm-agent
sudo apt install --no-install-recommends php8.1 -y
sudo apt install php-cli unzip curl software-properties-common -y
curl -sS https://getcomposer.org/installer -o composer-setup.php
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
sudo composer self-update


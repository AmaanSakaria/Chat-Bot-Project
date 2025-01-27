#!/bin/bash
 
# This file will contain the output of my LEMP Stack unit tests.
sudo touch /root/test.txt
 
# Setup Nginx. Starts and enables nginx on a server reboot. The second command will only run if the first command is successful. 
sudo apt -y install nginx 
sudo systemctl start nginx && sudo systemctl enable nginx 
sudo systemctl status nginx > /root/test.txt
 
# Install/Start MariaDB
sudo apt -y install mariadb-server
sudo systemctl start mariadb && sudo systemctl enable mariadb 
sudo systemctl status mariabd >> /root/test.txt
 
# Install PHP 
sudo apt -y install php-fpm php php-cli php-common php-imap  php-snmp php-xml php-zip php-mbstring php-curl php-mysqli php-gd php-intl
sudo php -v >> /root/test.txt
 
# This moves the nginx.conf file to the located where configuation files and typically placed.  
sudo mv /root/Chat-Bot-Project/nginx.conf /etc/nginx/conf.d/nginx.conf
 
# Generates a DNH record for an EC2 Instance.
dns_record=$(curl -s icanhazip.com | sed 's/^/ec2-/; s/\./-/g; s/$/.compute-1.amazonaws.com/')
 
# Updates the Nginx config file with the server name of the EC2 Instance 
sed -i "s/SERVERNAME/$dns_record/g" /etc/nginx/conf.d/nginx.conf
 
# Disabling the defaut config file 
sudo rm /etc/nginx/sites-enabled/default
 
# This will only reload nginx if the test is successful 
nginx -t && systemctl reload nginx
 
# Run the wordpress_install script
sudo bash /root/Chat-Bot-Project/

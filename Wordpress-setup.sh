#!/bin/bash
 
# Entering the html directory 
cd /var/www/html
 
# Install the unzip package 
sudo apt -y install unzip
 
# Install/Unzip/Remove latest zip file for clean code
sudo wget https://wordpress.org/latest.zip
sudo unzip latest.zip
sudo rm latest.zip
 
# Create a MariaDB Database and a User for the WordPress Site  
# Auto Generate password for use in WordPress Database - security
username=$(tr -dc 'A-Za-z' < /dev/urandom | head -c 25)
password=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 25)
 
echo $username >> credentials.txt
echo $password > credentials.txt
 
# Create a MariaDB Database and a User for the WordPress Site  
sudo mysql -e "CREATE DATABASE IF NOT EXISTS $username"
sudo mysql -e "CREATE USER $username@localhost identified by '$password'"
sudo mysql -e "GRANT ALL PRIVILEGES ON $username.* to $username@localhost"
sudo mysql -e "FLUSH PRIVILEGES" # Applies to everything you've done
 
sudo mv /var/www/html/wordpress/wp-config-sample.php /var/www/html/wp-config.php
sudo chmod 640 /var/www/html/wp-config.php 
sudo chown -R www-data:www-data /var/www/html/wp-config.php
 
sed -i "s/password_here/$password/g" /var/www/html/wp-config.php
sed -i "s/username_here/$username/g" /var/www/html/wp-config.php
sed -i "s/database_name_here/$username/g" /var/www/html/wp-config.php

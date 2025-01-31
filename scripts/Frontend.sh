#!/bin/bash

# Log file path
LOG_FILE="/var/log/script_execution.log"

# Function to check the exit status of the last executed command
check_exit_status() {
    if [ $? -ne 0 ]; then
        echo "Error: $1 failed." | tee -a $LOG_FILE
        exit 1
    else
        echo "$1 succeeded." | tee -a $LOG_FILE
    fi
}

# Clear the log file at the beginning of the script
> $LOG_FILE

# Update and Upgrade package lists
echo "Running apt update..." | tee -a $LOG_FILE
sudo apt -y update && sudo apt -y upgrade
check_exit_status "apt update and upgrade"

# Install the AWS CLI tool using Snap for managing AWS resources
snap install aws-cli --classic

# Run another update and upgrade to ensure all packages are up-to-date
sudo apt -y update && sudo apt -y upgrade

# Create a test file for debugging purposes
sudo touch /home/ubuntu/testing.txt

# Install and start Nginx web server
sudo apt -y install nginx
sudo systemctl start nginx && sudo systemctl enable nginx 

# Check the status of Nginx and log it to the test file
sudo systemctl status nginx > /home/ubuntu/testing.txt

# Install PHP and necessary extensions for WordPress
sudo apt -y install php-fpm php php-cli php-common php-imap php-snmp php-xml php-zip php-mbstring php-curl php-mysqli php-gd php-intl

# Log PHP version to the test file for verification
sudo php -v >> /home/ubuntu/testing.txt

# Append custom Nginx configuration to a test file
cat /home/ubuntu/WordPress_Deployment/configs/nginx.conf >> testing.txt

# Move the Nginx configuration file to the appropriate directory
sudo mv /home/ubuntu/WordPress_Deployment/configs/nginx.conf /etc/nginx/conf.d/epa-domain.conf

# Validate and reload Nginx with the new configuration
nginx -t && systemctl reload nginx 

# Update package list and install Certbot for SSL certificate management
sudo apt -y update && sudo apt -y upgrade
sudo apt -y install certbot
sudo apt -y install python3-certbot-nginx

# Define email and domain variables for SSL certificate registration
EMAIL="REPLACE_EMAIL"
DOMAIN="REPLACE_DOMAIN"

# Obtain and install an SSL certificate using Certbot
sudo certbot --nginx --non-interactive --agree-tos --email $EMAIL -d $DOMAIN

# Perform another Nginx configuration test and reload if successful
sudo nginx -t && systemctl reload nginx

# Install WordPress by downloading and extracting it
sudo rm -rf /var/www/html
sudo apt -y install unzip 
sudo wget -O /var/www/latest.zip https://wordpress.org/latest.zip 
sudo unzip /var/www/latest.zip -d /var/www/
sudo rm /var/www/latest.zip 

# Rename extracted WordPress folder to match web root
mv /var/www/wordpress /var/www/html

# Set up WordPress configuration file with appropriate permissions
sudo mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sudo chmod 640 /var/www/html/wp-config.php 
sudo chown -R www-data:www-data /var/www/html/
sudo find /var/www/html/ -type d -exec chmod 0755 {} \;
sudo find /var/www/html/ -type f -exec chmod 0644 {} \;

# Update wp-config.php with database credentials
sed -i "s/username_here/DB_USERNAME/g" /var/www/html/wp-config.php
sed -i "s/password_here/DB_PASSWORD/g" /var/www/html/wp-config.php
sed -i "s/database_name_here/DB_USERNAME/g" /var/www/html/wp-config.php
sed -i "s/localhost/BACKEND_IP/g" /var/www/html/wp-config.php

# Fetch WordPress security salts and insert them into wp-config.php
SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt/)
STRING='put your unique phrase here'
printf '%s\n' "g/$STRING/d" a "$SALT" . w | ed -s /var/www/html/wp-config.php

# Backup wp-config.php file to an AWS S3 bucket
aws s3 cp /var/www/html/wp-config.php s3://mariadbdatabase

# Install and run chkrootkit for rootkit detection
sudo apt update
sudo apt install chkrootkit -y

# Run chkrootkit scan and save the results
sudo chkrootkit > chkrootkit_output.txt

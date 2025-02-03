#!/bin/bash

# Log File
LOG_FILE="/var/log/script_execution.log"

# Function to Verify Command Execution
verify_command() {
    if [ $? -ne 0 ]; then
        echo "Error: $1 failed." | tee -a $LOG_FILE
        exit 1
    else
        echo "$1 completed successfully." | tee -a $LOG_FILE
    fi
}

# Reset Log File
> $LOG_FILE

# Update Packages
echo "Running package update..." | tee -a $LOG_FILE
sudo apt update -y && sudo apt upgrade -y
verify_command "System Update"

# Install AWS CLI
snap install aws-cli --classic

# Install & Configure Nginx
sudo apt install -y nginx
sudo systemctl enable nginx && sudo systemctl start nginx
verify_command "Nginx Installation"

# Install PHP & Extensions for WordPress
sudo apt install -y php-fpm php php-cli php-common php-imap php-snmp php-xml php-zip php-mbstring php-curl php-mysqli php-gd php-intl

# Download & Configure WordPress
sudo rm -rf /var/www/html
sudo wget -O /var/www/latest.zip https://wordpress.org/latest.zip
sudo unzip /var/www/latest.zip -d /var/www/
mv /var/www/wordpress /var/www/html

# Update wp-config.php with Database Details
sed -i "s/username_here/DB_USERNAME/g" /var/www/html/wp-config.php
sed -i "s/password_here/DB_PASSWORD/g" /var/www/html/wp-config.php
sed -i "s/database_name_here/DB_USERNAME/g" /var/www/html/wp-config.php
sed -i "s/localhost/BACKEND_IP/g" /var/www/html/wp-config.php

# Secure WordPress Config & Permissions
chown -R www-data:www-data /var/www/html/
find /var/www/html/ -type d -exec chmod 0755 {} \;
find /var/www/html/ -type f -exec chmod 0644 {} \;

# Save Config to S3
aws s3 cp /var/www/html/wp-config.php s3://chat-bot-project-s3

# Install chkrootkit for Security Scanning
# Install and run chkrootkit for rootkit detection
sudo apt update
sudo apt install chkrootkit -y
 
# Run chkrootkit scan and save the results
sudo chkrootkit > chkrootkit_output.txt

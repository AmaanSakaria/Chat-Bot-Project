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
sudo apt update -y && sudo apt -y upgrade
verify_command "System Update"
 
# Install AWS CLI
snap install aws-cli --classic
 
# Run another update and upgrade to ensure all packages are up-to-date
sudo apt -y update && sudo apt -y upgrade
 
# Install & Configure Nginx
sudo apt -y install nginx
sudo systemctl start nginx && sudo systemctl enable nginx
verify_command "Nginx Installation"
 
# Install PHP & Extensions for WordPress
sudo apt install -y php-fpm php php-cli php-common php-imap php-snmp php-xml php-zip php-mbstring php-curl php-mysqli php-gd php-intl
 
# Move the Nginx configuration file to the appropriate directory
sudo mv /home/ubuntu/Chat-Bot-Project/configs/nginx.conf /etc/nginx/conf.d/domain.conf
 
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
 
sudo nginx -t && systemctl reload nginx
 
# Download & Configure WordPress
sudo rm -rf /var/www/html
sudo apt -y install unzip
sudo wget -O /var/www/latest.zip https://wordpress.org/latest.zip
sudo unzip /var/www/latest.zip -d /var/www/
mv /var/www/wordpress /var/www/html

#Installing ua92-chatbot plugin
aws s3 cp s3://chat-bot-project-s3/ua92-chatbot /var/www/html/wp-content/plugins/ua92-chatbot --recursive

# Secure WordPress Config & Permissions
sudo mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sudo chmod 640 /var/www/html/wp-config.php
chown -R www-data:www-data /var/www/html/
find /var/www/html/ -type d -exec chmod 0755 {} \;
find /var/www/html/ -type f -exec chmod 0644 {} \;
 
# Update wp-config.php with Database Details
sed -i "s/username_here/DB_USERNAME/g" /var/www/html/wp-config.php
sed -i "s/password_here/DB_PASSWORD/g" /var/www/html/wp-config.php
sed -i "s/database_name_here/DB_USERNAME/g" /var/www/html/wp-config.php
sed -i "s/localhost/BACKEND_IP/g" /var/www/html/wp-config.php
 
# Fetch WordPress security salts and insert them into wp-config.php
SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt/)
STRING='put your unique phrase here'
printf '%s\n' "g/$STRING/d" a "$SALT" . w | ed -s /var/www/html/wp-config.php
 
# Save Config to S3
aws s3 cp /var/www/html/wp-config.php s3://chat-bot-project-s3
 
# Install chkrootkit for Security Scanning
# Install and run chkrootkit for rootkit detection
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install chkrootkit -y >> /var/log/install_chkrootkit.log 2>&1
 
# Run chkrootkit scan and save the results
sudo chkrootkit > chkrootkit_output.txt


#!/bin/bash
 
# System Update & Upgrade
sudo apt update -y && sudo apt -y upgrade
 
# Install AWS CLI for managing AWS resources
snap install aws-cli --classic
 
# Install MariaDB server & client
apt -y install mariadb-server mariadb-client
 
# Allow external connections to MariaDB
sed -i 's/^bind-address\s*=.*/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf
 
# Restart MariaDB & Verify Status
mysqladmin ping && systemctl restart mariadb
 
# Define database credentials
DB_USER=DB_USERNAME
DB_PASS=DB_PASSWORD
 
# Backup credentials to a temporary file
echo $DB_USER > creds.txt
echo $DB_PASS >> creds.txt
 
# Download WordPress database backup from S3
aws s3 cp s3://chat-bot-project-s3/chatbot_dump.sql /tmp/chatbot_dump.sql
 
# Create database & user if not exists
sudo mysql -e "CREATE DATABASE IF NOT EXISTS $DB_USER"
sudo mysql -e "CREATE USER IF NOT EXISTS '$DB_USER'@'FRONTEND_IP' IDENTIFIED BY '$DB_PASS'"
sudo mysql -e "GRANT ALL PRIVILEGES ON $DB_USER.* TO '$DB_USER'@'FRONTEND_IP'"
sudo mysql -e "FLUSH PRIVILEGES"
 
# Restore database backup
sudo mysql $DB_USER < /tmp/chatbot_dump.sql
sudo rm /tmp/chatbot_dump.sql
 
# Securely store credentials in AWS S3
aws s3 cp creds.txt s3://chat-bot-project-s3

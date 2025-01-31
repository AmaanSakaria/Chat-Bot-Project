#!/bin/bash

# Update and upgrade system packages
sudo apt -y update && sudo apt -y upgrade

# Install the AWS CLI tool using Snap for managing AWS resources
snap install aws-cli --classic

# Install MariaDB server and client
apt -y install mariadb-server mariadb-client

# Modify MariaDB configuration to allow external connections
sed -i 's/^bind-address\s*=.*/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

# Restart MariaDB service and check if it is running
mysqladmin ping && systemctl restart mariadb

# Database username and password variables
username=DB_USERNAME
password=DB_PASSWORD

# Store credentials in a temporary file for backup
echo $username > creds.txt
echo $password >> creds.txt

aws s3 cp s3://chat-bot-project-s3/wordpress_dump.sql.gz /tmp/wordpress_dump.sql.gz
sudo gunzip /tmp/wordpress_dump.sql.gz

# Create the database and user if they do not exist
sudo mysql -e "CREATE DATABASE IF NOT EXISTS $username"
sudo mysql -e "CREATE USER IF NOT EXISTS '$username'@'FRONTEND_IP' IDENTIFIED BY '$password'"
sudo mysql -e "GRANT ALL PRIVILEGES ON $username.* TO '$username'@'FRONTEND_IP'"
sudo mysql -e "FLUSH PRIVILEGES"

# Restore the database backup
sudo mysql $username < /tmp/wordpress_dump.sql.gz
sudo rm /tmp/wordpress_dump.sql.gz

# Securely store the credentials file in AWS S3 for later use or backup
aws s3 cp creds.txt s3://chat-bot-project-s3

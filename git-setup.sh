#!/bin/bash
# sudo apt -y install git
sudo apt -y update
sudo apt -y upgrade
sudo git clone https://https://github.com/AmaanSakaria/Chat-Bot-Project /root/Chat-Bot-Project
sudo chmod -R 755 /root/Chat-Bot-Project 
sudo bash /root/Chat-Bot-Project/lemp-setup.sh

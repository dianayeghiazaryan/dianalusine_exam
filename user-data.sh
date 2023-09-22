#!/bin/bashsudo apt update -y
sudo apt install apache2 -ysudo systemctl start apache2
sudo systemctl enable apache2sudo apt update -y
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:deadsnakes/ppasudo apt update -y
sudo apt install python3.8 -y
sudo apt-add-repository ppa:ansible/ansiblesudo apt update -y
sudo apt install ansible -y
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
     echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
 https://pkg.jenkins.io/debian binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/nullsudo apt-get update -y
sudo apt-get install fontconfig openjdk-17-jre -ysudo apt-get install jenkins -y
pub   rsa4096 2023-03-27 [SC] [expires: 2026-03-26]
63667EE74BBA1F0A08A698725BA31D57EF5975CA
uid                      Jenkins Project
sub   rsa4096 2023-03-27 [E] [expires: 2026-03-26]
sudo systemctl enable jenkins
sudo systemctl start jenkins

#!/bin/bash

sudo apt update -y
sudo apt install apache2 -y
sudo systemctl start apache2
sudo systemctl enable apache2
sudo apt update -y

sudo apt install openjdk-11-jdk -y
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins
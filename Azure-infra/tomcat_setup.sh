#!/bin/bash

set -e

# Update system
sudo apt-get update -y
sudo apt-get upgrade -y

# Install Java
sudo apt install openjdk-17-jdk -y

# Define variables
TOMCAT_VERSION="9.0.105"
TOMCAT_DIR="/opt/tomcat"

# Download and install Tomcat
cd /opt
sudo wget https://downloads.apache.org/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz
sudo tar -xvzf apache-tomcat-${TOMCAT_VERSION}.tar.gz
sudo mv apache-tomcat-${TOMCAT_VERSION} ${TOMCAT_DIR}
sudo rm -f apache-tomcat-${TOMCAT_VERSION}.tar.gz
sudo chmod -R 755 ${TOMCAT_DIR}

# Create systemd service
sudo tee /etc/systemd/system/tomcat.service > /dev/null <<EOF
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=oneshot

Environment=JAVA_HOME=/usr/lib/jvm/java-1.17.0-openjdk-amd64        
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'
ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

User=root
Group=root
UMask=0007
RestartSec=10
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start Tomcat
sudo systemctl daemon-reload
sudo systemctl enable tomcat
sudo systemctl start tomcat

# Log status
sudo systemctl status tomcat

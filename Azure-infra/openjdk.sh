#!/bin/bash
sudo apt update && sudo apt install openjdk-21-jdk
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64/
export PATH=$JAVA_HOME/bin:$PATH
java -version
sudo systemctl restart jenkins
sudo systemctl status jenkins

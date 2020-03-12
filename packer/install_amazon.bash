#!/bin/bash

set -x

# For xmlstarlet
sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

sudo yum update -y

sleep 10

# Just to be safe removing previously available java if present
sudo yum remove -y java

sudo yum install -y python2-pip jq unzip vim tree biosdevname nc bind-utils at screen tmux xmlstarlet git java-1.8.0-openjdk nc

sudo -H pip install awscli bcrypt
sudo -H pip install --upgrade awscli
sudo -H pip install --upgrade aws-ec2-assign-elastic-ip

sudo yum clean all
sudo rm -rf /var/cache/yum/
exit 0


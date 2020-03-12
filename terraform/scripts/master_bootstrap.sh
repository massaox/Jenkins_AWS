#!/bin/bash

set -ex
install_packages () {
yum install lvm2 nginx -y
}

setup_lvm () {
## Setup up LVM for persistent storage of Jenkins home directory
vgchange -ay

DEVICE_FS=`blkid -o value -s TYPE ${DEVICE} || echo ""`
if [ "`echo -n $DEVICE_FS`" == "" ] ; then
  # wait for the device to be attached
  DEVICENAME=`echo "${DEVICE}" | awk -F '/' '{print $3}'`
  DEVICEEXISTS=''
  while [[ -z $DEVICEEXISTS ]]; do
    echo "checking $DEVICENAME"
    DEVICEEXISTS=`lsblk |grep "$DEVICENAME" |wc -l`
    if [[ $DEVICEEXISTS != "1" ]]; then
      sleep 15
    fi
  done
  pvcreate ${DEVICE}
  vgcreate data ${DEVICE}
  lvcreate --name jenkins-master -l 100%FREE data
  mkfs.ext4 /dev/data/jenkins-master
fi
mkdir -p /var/lib/jenkins
echo '/dev/data/jenkins-master /var/lib/jenkins ext4 defaults 0 0' >> /etc/fstab
mount /dev/data/jenkins-master
}

setup_nginx () {
# Configure NGINX and URL authentication htpasswd

sed -i 's/80 default_server;/80;/g' /etc/nginx/nginx.conf

cat > /etc/nginx/conf.d/jenkins.conf <<EOF
upstream jenkins {
  keepalive 32; # keepalive connections
  server 127.0.0.1:8080; # jenkins ip and port
}

server {
  listen          80 default_server;       # Listen on port 80 for IPv4 requests

  server_name     jenkins.rafaeltanaka.tech;

  #this is the jenkins web root directory (mentioned in the /etc/default/jenkins file)
  root            /var/run/jenkins/war/;

  access_log      /var/log/nginx/jenkins-access.log;
  error_log       /var/log/nginx/jenkins-error.log;
  ignore_invalid_headers off; #pass through headers from Jenkins which are considered invalid by Nginx server.

  location ~ "^/static/[0-9a-fA-F]{8}\/(.*)$" {
    #rewrite all static files into requests to the root
    #E.g /static/12345678/css/something.css will become /css/something.css
    rewrite "^/static/[0-9a-fA-F]{8}\/(.*)" /\$1 last;
  }

  location /userContent {
    #have nginx handle all the static requests to the userContent folder files
    #note : This is the \$JENKINS_HOME dir
        root /var/lib/jenkins/;
    if (!-f \$request_filename){
      #this file does not exist, might be a directory or a /**view** url
      rewrite (.*) /\$1 last;
          break;
    }
        sendfile on;
  }

  location / {
#      auth_basic            "Restricted";
#      auth_basic_user_file  /etc/nginx/htpasswd;
      sendfile off;
      proxy_pass         http://jenkins;
      proxy_redirect     default;
      proxy_http_version 1.1;

      proxy_set_header   Host              \$host;
      proxy_set_header   X-Real-IP         \$remote_addr;
      proxy_set_header   X-Forwarded-For   \$proxy_add_x_forwarded_for;
      proxy_set_header   X-Forwarded-Proto \$scheme;
      proxy_max_temp_file_size 0;

      #this is the maximum upload size
      client_max_body_size       10m;
      client_body_buffer_size    128k;

      proxy_connect_timeout      90;
      proxy_send_timeout         90;
      proxy_read_timeout         90;
      proxy_buffering            off;
      proxy_request_buffering    off; # Required for HTTP CLI commands in Jenkins > 2.54
      proxy_set_header Connection ""; # Clear for keepalive
  }

}
EOF

# Enable Nginx to start on bott and start it
systemctl enable nginx
systemctl start nginx
}

### script starts here ###
install_packages
setup_lvm
setup_nginx 

echo "Done"
exit 0


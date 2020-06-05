#!/bin/bash
yum -y install httpd
echo "hello from terraform" >> /var/www/html/index.html
service httpd start
chkconfig httpd on
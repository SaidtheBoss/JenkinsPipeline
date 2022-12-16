#!/bin/bash
yum install -y httpd
mkdir /var/www/html/images
echo "<h1> $(hostname -I) This is images site</h1>" > /var/www/html/images/index.html
systemctl start httpd
systemctl enable httpd
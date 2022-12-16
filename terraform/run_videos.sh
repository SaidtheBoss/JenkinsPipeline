#!/bin/bash
yum install -y httpd
mkdir /var/www/html/videos
echo "<h1> $(hostname -I) This is videos site </h1>" > /var/www/html/videos/index.html
systemctl start httpd
systemctl enable httpd
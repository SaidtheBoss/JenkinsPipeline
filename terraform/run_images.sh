#!/bin/bash
yum install -y httpd 
yum install -y unzip wget

cd /var/www/html/
wget https://test-web-sergio.s3.amazonaws.com/images.zip
unzip images.zip
sed -i "1i $(hostname -I)" /var/www/html/images/index.html
systemctl start httpd
systemctl enable httpd
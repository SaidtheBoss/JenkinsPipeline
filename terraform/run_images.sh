#!/bin/bash
yum install -y httpd
mkdir /var/www/html/images
echo "<img src="https://i.redd.it/scupjyjwyqs11.jpg">" > /var/www/html/images/index.html
systemctl start httpd
systemctl enable httpd

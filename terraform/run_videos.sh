#!/bin/bash
yum install -y httpd
mkdir /var/www/html/videos
echo "<iframe width="420" height="345" src="https://www.youtube.com/embed/KZckZ6ZIVTU?autoplay=1&mute=1">" > /var/www/html/videos/index.html
systemctl start httpd
systemctl enable httpd

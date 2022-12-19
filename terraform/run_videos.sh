#!/bin/bash
yum install -y httpd
mkdir /var/www/html/videos
echo "<h1> $(hostname -I) This is videos site </h1>" > /var/www/html/videos/index.html
echo "<iframe width="420" height="345" src="https://www.youtube.com/embed/KZckZ6ZIVTU?autoplay=1&mute=1">" > /var/www/html/videos/index.html
echo "<img src="https://mir-s3-cdn-cf.behance.net/project_modules/max_1200/5eeea355389655.59822ff824b72.gif">" > /var/www/html/videos/index.html
systemctl start httpd
systemctl enable httpd

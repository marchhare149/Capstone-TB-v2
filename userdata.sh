#!/bin/bash
set -euxo pipefail

yum update -y
amazon-linux-extras enable php8.0
yum clean metadata
yum install -y httpd php php-mysqlnd wget tar

systemctl enable --now httpd

cd /var/www/html
rm -rf *
wget -q https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* /var/www/html/
rm -rf wordpress latest.tar.gz

cp wp-config-sample.php wp-config.php
sed -i "s/database_name_here/wordpress/" wp-config.php
sed -i "s/username_here/wpuser/" wp-config.php
sed -i "s/password_here/wpPassword123!/" wp-config.php
sed -i "s/localhost/wordpress-db.chy6uimi0gsm.us-west-2.rds.amazonaws.com/" wp-config.php

chown -R apache:apache /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

# ensure index.php priority
grep -q "DirectoryIndex" /etc/httpd/conf/httpd.conf || echo "DirectoryIndex index.php index.html" >> /etc/httpd/conf/httpd.conf

systemctl restart httpd
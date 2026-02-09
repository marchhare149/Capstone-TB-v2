#!/bin/bash
yum update -y
amazon-linux-extras install php8.0 -y
yum install -y httpd mysql

systemctl start httpd
systemctl enable httpd

cd /var/www/html
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz

cp -r wordpress/* /var/www/html/
rm -rf wordpress latest.tar.gz

chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

cp wp-config-sample.php wp-config.php

sed -i "s/database_name_here/wordpress/" wp-config.php
sed -i "s/username_here/wpuser/" wp-config.php
sed -i "s/password_here/wpPassword123!/" wp-config.php
sed -i "s/localhost/wordpress-db.chy6uimi0gsm.us-west-2.rds.amazonaws.com/" wp-config.php

systemctl restart httpd

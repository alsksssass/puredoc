#!/bin/sh

set -e

url=$WORDPRESS_URL

dbname=$WORDPRESS_DB_NAME
dbuser=$WORDPRESS_DB_USER
dbpwd=$WORDPRESS_DB_PASSWORD
dbhost=$WORDPRESS_DB_HOST

adminname=$WORDPRESS_ADMIN_NAME
adminpwd=$WORDPRESS_ADMIN_PWD
adminemail=$WORDPRESS_ADMIN_EMAIL

username=$WORDPRESS_USER_NAME
userpwd=$WORDPRESS_USER_PWD
useremail=$WORDPRESS_USER_EMAIL

cd /var/lib/nginx/wordpress

if [ ! -f /var/lib/nginx/wordpress/index.php ]; then
	wp core download --path=/var/lib/nginx/wordpress --locale=ko_KR
fi

if [ ! -f /var/lib/nginx/wordpress/wp-config.php ]; then
	wp core config --dbname=$dbname --dbuser=$dbuser --dbpass=$dbpwd --dbhost=$dbhost
	wp config set WP_REDIS_HOST redis
	wp config set WP_REDIS_PORT 6379
	wp core install --url=$WORDPRESS_URL --title="Inception" --admin_user=$adminname --admin_password=$adminpwd --admin_email=$adminemail
	wp user create $username $useremail --role=subscriber --user_pass=$userpwd
	wp plugin install redis-cache --activate
	wp redis enable
fi

if [ -z $(getent passwd wordpress) ]; then
	adduser -D wordpress
fi

chown -R wordpress:wordpress .
chmod -R 755 .

exec php-fpm83 -F;

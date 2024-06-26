#!/bin/sh

set -e

user=$MYSQL_USER
pwd=$MYSQL_PASSWORD
database=$MYSQL_DATABASE

cat << EOF > create_user_and_database.sql
CREATE DATABASE IF NOT EXISTS $database;
CREATE USER IF NOT EXISTS $user@'%';
SET PASSWORD FOR $user@'%'=PASSWORD("$pwd");
GRANT ALL PRIVILEGES ON $database.* TO $user@'%' IDENTIFIED BY '$pwd';
FLUSH PRIVILEGES;
EOF

mysql_install_db --user=mysql --datadir=/var/lib/mysql

mkdir -p /run/mysqld
touch /run/mysqld/mysqld.sock

mariadbd -u root &

sleep 3

mariadb -u root < create_user_and_database.sql

pkill mariadbd

if [ -z $(getent passwd mariadb) ]; then
	adduser -D mariadb
	chown -R mariadb:mariadb /var/lib/mysql
fi

chmod 755 -R /var/lib/mysql

exec mariadbd -u root

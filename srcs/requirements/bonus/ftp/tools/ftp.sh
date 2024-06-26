#!/bin/sh

set -e

passwd="$FTP_PASSWORD"

# wordpress 사용자가 존재하지 않으면 추가
if ! getent passwd wordpress > /dev/null; then
    #echo "Adding user wordpress"
    #echo "wordpress:$passwd" | adduser -h /var/lib/nginx/wordpress -s /sbin/nologin -D wordpress
    echo -e "$passwd\n$passwd" | adduser wordpress -h /var/lib/nginx/wordpress
	echo "end add_user"
fi

# vsftpd 실행
exec dumb-init -- vsftpd /etc/vsftpd/vsftpd.conf


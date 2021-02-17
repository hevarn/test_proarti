#!/bin/bash

uid=$(stat -c %u /srv)
gid=$(stat -c %g /srv)

if [ "$uid" == 0 ] && [ "$gid" == 0 ]; then
    sed -i "s/user = www-data/user = root/g" /usr/local/etc/php-fpm.d/www.conf
    sed -i "s/group = www-data/group = root/g" /usr/local/etc/php-fpm.d/www.conf

    if [ $# -eq 0 ]; then
        supervisord
    else
        exec "$@"
    fi
fi

sed -i -r "s/foo:x:\d+:\d+:/foo:x:$uid:$gid:/g" /etc/passwd
sed -i -r "s/bar:x:\d+:/bar:x:$gid:/g" /etc/group

sed -i "s/user = www-data/user = foo/g" /usr/local/etc/php-fpm.d/www.conf
sed -i "s/group = www-data/group = bar/g" /usr/local/etc/php-fpm.d/www.conf

user=$(grep ":x:$uid:" /etc/passwd | cut -d: -f1)
chown "$user":bar /home
chown -R "$user":bar /srv/var

if [ $# -eq 0 ]; then
    supervisord
else
    exec gosu "$user" "$@"
fi

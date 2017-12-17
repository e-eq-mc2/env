#!/bin/sh -x

cp simplehttpd /etc/init.d/
chmod +x /etc/init.d/simplehttpd
chkconfig --add simplehttpd
sudo service simplehttpd start

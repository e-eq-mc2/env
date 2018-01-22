#!/bin/sh -x

sudo cp simplehttpd /etc/init.d/
sudo chmod +x /etc/init.d/simplehttpd
sudo chkconfig --add simplehttpd
sudo service simplehttpd start

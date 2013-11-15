#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
echo "============== Starting packages installer ==============="

# node settings
NODE_VERSION=0.10.22
NODE_SOURCE=http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.gz

echo "installing base packages"
sudo apt-get install -y vim curl python-software-properties git

echo "Updating packages.."
sudo apt-get update

echo "Getting the lastet version of PHP"
sudo apt-repository -y ppa:ondrej/php5

echo "Updating packages...again..."
sudo apt-get update

#Install nginx
sudo apt-get -y install nginx
apt-get -y install nginx-extras;

#Mysql prompt settings to silently install
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

#Install PHP & It's deps
echo " "
echo "========= Installing PHP & Its' Dependencies ============="
apt-get -y install php5 php5-fpm php5-common php5-curl php5-json php5-dev php5-gd php5-imagick php5-mcrypt php5-memcache php5-mysql mysql-server php5-pspell php5-snmp php5-sqlite sqlite php5-xmlrpc php5-xsl php-pear libssh2-php php5-cli php5-xdebug > /dev/null

#Install PHPMyadmin & provide defaults for the prompts
#sudo apt-get -q -y install -y phpmyadmin
# apt-get -q -y phpmyadmin
# echo 'phpmyadmin phpmyadmin/dbconfig-install boolean true' | debconf-set-selections
# echo 'phpmyadmin phpmyadmin/app-password-confirm password root' | debconf-set-selections
# echo 'phpmyadmin phpmyadmin/mysql/admin-pass password root' | debconf-set-selections
# echo 'phpmyadmin phpmyadmin/mysql/app-pass password root' | debconf-set-selections
# echo 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2' | debconf-set-selections

#Configure Xdebug
echo "configuring xdebug"
cat << EOF | sudo tee -a /etc/php5/mods-availible/xdebug.ini

xdebug.scream=1
xdebug.cli_color=1
xdebug.show_local_vars=1

EOF

echo "Setting up shared folders with vagrant: mapping it the the my webroot folder"
sudo rm -rf /usr/share/nginx/www
sudo ln -sf /vagrant /usr/share/nginx/www
echo "<?php phpinfo(); ?>" >  /vagrant/index.php

echo "Setting up Nginx default vhost in sites-availible"
sudo chmod 777 /etc/nginx/sites-available/default
sudo curl https://raw.github.com/peb7268/vagrant/master/node-nginx-php/sites-availible/default > /etc/nginx/sites-available/default

#Setup Node

#Install Package Managers
echo "installing composer"
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

#use this command for the next two operations: replaces abc with XYZ
#sed -i -e 's/abc/XYZ/g' /tmp/file.txt

#Open the /etc/php5/fpm/php.ini file and change the cgi.fix_pathinfo from 1 to 0 and un comment it.
sudo sed -i -e 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php5/fpm/php.ini

#Open this /etc/php5/fpm/pool.d/www.conf file and change the listen line from listen 127.0.0.1:9000 to /var/run/php5-fpm.sock
sudo sed -i -e 's/listen = 127.0.0.1:9000/listen = \/var\/run\/php5-fpm.sock/g' /etc/php5/fpm/pool.d/www.conf

# Install PHPUnit
# pear upgrade-all
# pear config-set auto_discover 1
# pear install -f --alldeps pear.phpunit.de/PHPUnit

#echo "==> add an nginx user"
#adduser --system --no-create-home nginx

# create the appropriate nginx links
#ln -sf /opt/nginx-$NGINX_VERSION /opt/nginx


#configuring .bashrc
echo "alias reload='source ~/.bashrc'" >> .bashrc
echo "alias nginxdir='cd /etc/nginx ~/.bashrc'" >> .bashrc
echo "alias qngx='sudo service nginx stop'" >> .bashrc
echo "alias sngx='sudo service nginx start'" >> .bashrc
echo "alias www='cd /usr/share/nginx/www/'" >> .bashrc

# ensure we have services setup
echo "==> Checking service configurations";
if [ ! -e /etc/init/nginx.conf ]
then
	echo "==> Installing nginx service";
fi

#Restart PHP-FPM
sudo service nginx restart
sudo service php5-fpm restart
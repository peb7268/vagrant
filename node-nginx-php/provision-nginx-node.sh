#!/bin/bash
echo "Starting packages installer."

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
echo "==> Installing PHP & Its' Dependencies"
apt-get -y install php5 php5-fpm php5-common php5-curl php5-json php5-dev php5-gd php5-imagick php5-mcrypt php5-memcache php5-mysql mysql-server php5-pspell php5-snmp php5-sqlite sqlite php5-xmlrpc php5-xsl php-pear libssh2-php php5-cli > /dev/null

#Install Xdebug
sudo apt-get install -y php5-xdebug

echo "configuring xdebug"

cat << EOF | sudo tee -a /etc/php5/mods-availible/xdebug.ini

xdebug.scream=1
xdebug.cli_color=1
xdebug.show_local_vars=1

EOF

echo "Setting up shared folders with vagrant: mapping it the the laravel public folder"
sudo rm -rf /var/www
sudo ln -sf ./ /usr/share/nginx/www/

echo "installing composer"
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer


#Open the ini and change the pathinfo from 1 to 0
#sudo vim /etc/php5/fpm/php.ini
#cgi.fix_pathinfo=0

#Open this www.conf file for php5 fpm and change the listen line from loopback:9000 to the following line:
#sudo nano /etc/php5/fpm/pool.d/www.conf
#listen = /var/run/php5-fpm.sock

#Restart PHP-FPM
#sudo service php5-fpm restart

# Install PHPUnit
# pear upgrade-all
# pear config-set auto_discover 1
# pear install -f --alldeps pear.phpunit.de/PHPUnit

echo "==> add an nginx user"
adduser --system --no-create-home nginx

# create the appropriate nginx links
#ln -sf /opt/nginx-$NGINX_VERSION /opt/nginx

# ensure we have services setup
echo "==> Checking service configurations";
if [ ! -e /etc/init/nginx.conf ]
then
	echo "==> Installing nginx service";
fi

#configuring .bashrc
echo "alias reload='source ~/.bashrc'" >> .bashrc
echo "alias nginxdir='cd /etc/nginx ~/.bashrc'" >> .bashrc
echo "alias qngx='sudo service nginx stop'" >> .bashrc
echo "alias sngx='sudo service nginx start'" >> .bashrc
echo "alias www='cd /usr/share/nginx/www/'" >> .bashrc

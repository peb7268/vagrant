#!/usr/bin/env bash

echo "Starting packages installer."

echo "Updating packages.."
sudo apt-get update

echo "installing MySql..."
sudo debconf--set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf--set-selections <<< 'mysql-server mysql-server/root_password_again password root'

echo "installing base packages"
sudo apt-get install -y vim curl python-software-properties

echo "Updating packages.."
sudo apt-get update

echo "Getting the lastet version of PHP"
sudo apt-repository -y ppa:ondrej/php5

echo "Updating packages...again..."
sudo apt-get update

echo "installing PHP specific packages"
sudo apt-get-install -y php5 apache2 libapache2-mod-php5 php5-curl php5-json php5-gd php5-mcrypt mysql-server-5.5 php5-mysql php5-cli php-pear sqlite php5-sqlite git-core

sudo apt-get install -y php5-xdebug

cat << EOF | sudo tee -a /etc/php5/mods-availible/xdebug.ini

xdebug.scream=1
xdebug.cli_color=1
xdebug.show_local_vars=1

EOF

echo "enable mod rewrite"
sudo a2enmod rewrite

echo "Setting up shared folders with vagrant: mapping it the the laravel public folder"
sudo rm -rf /var/www
sudo ln -sf /vagrant/public /var/www

echo "Turn on PHP errors"
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/apache2/php.ini

# Install PHPUnit
pear upgrade-all
pear config-set auto_discover 1
pear install -f --alldeps pear.phpunit.de/PHPUnit


# Setup hosts file
VHOST=$(cat <<EOF
<VirtualHost *:80>
  DocumentRoot "/vagrant/public"
  ServerName localhost
  <Directory "/vagrant/public">
    AllowOverride All
  </Directory>
</VirtualHost>
EOF
)
echo "${VHOST}" > /etc/apache2/sites-enabled/000-default

echo "restarting apache"
sudo service apache2 restart

echo "installing composer"
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

#Laravel specific stuff here
composer create-project laravel/laravel
cd laravel;
sudo composer install

# Make some laravel directories writable
chmod --recursive a+rw /var/www/public/packages
chmod --recursive a+rw /var/www/app/config/packages
chmod --recursive a+rw /var/www/app/storage

# Set up a dataase for your project
echo "CREATE DATABASE IF NOT EXISTS YOUR_DB_NAME" | mysql
echo "GRANT ALL PRIVILEGES ON YOUR_DB_NAME.* TO 'root'@'localhost' IDENTIFIED BY 'DB_PASSWORD'" | mysql

# Run artisan migrate to setup the database and schema, then seed it
php artisan migrate --env=development
php artisan db:seed --env=development

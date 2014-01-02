#!/usr/bin/env bash

#Get the project name:
echo "== Install ========================================"
PROJECT_NAME=intengodev

echo "--- Updating packages list ---"
apt-get update

echo "--- MySQL time ---"
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

echo "--- Installing base packages ---"
sudo apt-get install -y vim curl python-software-properties

#echo "--- We want the bleeding edge of PHP, right master? ---"
sudo add-apt-repository -y ppa:ondrej/php5

#echo "--- Updating packages list ---"
sudo apt-get update

echo "--- Installing PHP-specific packages ---"
sudo apt-get install -y php5 php5-cli apache2 libapache2-mod-php5 php5-curl php5-gd php5-mcrypt libreadline5 mysql-server-5.5 php5-mysql git-core

echo "--- Installing and configuring Xdebug ---"
sudo apt-get install -y php5-xdebug

cat << EOF | sudo tee -a /etc/php5/mods-available/xdebug.ini
xdebug.scream=1
xdebug.cli_color=1
xdebug.show_local_vars=1
EOF

echo "--- What developer codes without errors turned on? Not you, master. ---"
sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/apache2/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/apache2/php.ini
sudo sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

echo "--- You like to tinker, don't you master? ---"
sed -i "s/disable_functions = .*/disable_functions = /" /etc/php5/cli/php.ini
sed -i "s/disable_functions = .*/disable_functions = /" /etc/php5/apache2/php.ini

echo "== Setting Up The Default conf file for $PROJECT_NAME =================================="
#Default Conf settings
CONF=$(cat <<EOF
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot "/var/www/public"
        ServerName dev.$PROJECT_NAME.com

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF
)
sudo chmod -R 777 /etc/apache2/sites-available
sudo rm -f /etc/apache2/sites-available/000-default.conf
echo "${CONF}" > /etc/apache2/sites-available/000-default.conf

#Set the DocumentRoot
sudo sed -i "s/DocumentRoot \/var\/www/DocumentRoot \/var\/www\/$PROJECT_NAME\/public/" /etc/apache2/sites-available/000-default.conf
#Set the ServerName
#sudo sed -i "s/#ServerName www.example.com/ServerName test_project.com/" /etc/apache2/sites-available/000-default.conf

#Remove the default sites availible conf and set the dev one as the default VHOST
#sudo rm -f /etc/apache2/sites-enabled/000-default.conf
#sudo ln -s ../sites-available/000-default 000-default

# Enable mod_rewrite
sudo a2enmod rewrite

echo "--- Setting document root ---"
cd /
sudo rm -rf /var/www
sudo ln -fs /vagrant /var/www

#Install PHPUnit
wget http://phar.phpunit.de/phpunit.phar
sudo chmod +x phpunit.phar
sudo mv phpunit.phar /usr/local/bin/phpunit

#Install Composer
cd /home/vagrant
curl -sS http://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

cd /var/www
#composer create-project laravel/laravel $PROJECT_NAME --prefer-dist #uncomment for a fresh L4 install
git clone https://peb7268:erford7268@github.com/Infosurv/icev2.git $PROJECT_NAME
cd $PROJECT_NAME; #switch into project name
sudo cp -Rf * ../ #copy everything into the root dir
sudo rm -rf $PROJECT_NAME

# Make some laravel directories writable
chmod -R a+rw public/packages
chmod -R a+rw app/config/packages
chmod -R a+rw app/storage

echo "--- Restarting Apache ---"
sudo service apache2 restart

#Run composer
sudo composer install

#Setup the DB & Set the local and prod configs ( Set these to whatever your project calls for )
cd /vagrant/app/config
sed -i "s/'database'  => 'dev_ice_testing'/'database'  => '$PROJECT_NAME'/" ./local/database.php
sed -i "s/'password'  => ''/'password'  => 'root'/" ./local/database.php

sed -i "s/'database'  => 'dev_read_it_later'  => 'mx.internal'/" ./database.php
sed -i "s/'password'  => ''/'password'  => 'u428GKzhTvyA7KrV'/" ./database.php

#Make a database for the project
echo "CREATE DATABASE IF NOT EXISTS $PROJECT_NAME" | mysql -uroot -proot
echo "GRANT ALL PRIVILEGES ON $PROJECT_NAME.* TO 'root'@'localhost' IDENTIFIED BY 'root'" | mysql -uroot -proot

#Install Redis
sudo apt-get install make
wget http://download.redis.io/releases/redis-2.8.3.tar.gz
tar xzf redis-2.8.3.tar.gz
cd redis-2.8.3
make
cd src
sudo mv redis-server /usr/local/bin/redis-server
sudo mv redis-cli /usr/local/bin/redis-cli
sudo mv redis-sentinel /usr/local/bin/redis-sentinel

#Cleanup
cd ../..
sudo rm -rf redis-2.8.3
rm redis-2.8.3.tar.gz

#Add some aliases to the bash profile
echo "alias artisan='php artisan'" >> /home/vagrant/.bash_profile
echo "alias app='cd /vagrant/app/'" >> /home/vagrant/.bash_profile
echo "alias reload='source ~/.bash_profile'" >> /home/vagrant/.bash_profile
source /home/vagrant/.bash_profile
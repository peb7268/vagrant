#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
echo "============== Starting packages installer ==============="
echo "Updating packages.."
sudo apt-get update

echo "installing base packages"
sudo apt-get install -y vim curl python-software-properties git

echo "Getting the lastet version of PHP"
sudo add-apt-repository -y ppa:ondrej/php5
sudo apt-get update
sudo apt-get upgrade -y

#Install nginx
sudo apt-get -y install nginx
sudo apt-get -y install nginx-extras

#Mysql prompt settings to silently install
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

echo " "
echo "========= Installing PHP & Its' Dependencies ============="
#libssh2-php not availible for newest php's yet
sudo apt-get -y install php5 php5-fpm php5-common php5-curl php5-json php5-dev php5-gd php5-imagick php5-mcrypt php5-memcache php5-mysql mysql-server php5-pspell php5-snmp php5-sqlite sqlite php5-xmlrpc php5-xsl php-pear php5-cli php5-xdebug > /dev/null

#Configure Xdebug
echo "configuring xdebug"
cat << EOF | sudo tee -a /etc/php5/mods-available/xdebug.ini

xdebug.scream=1
xdebug.cli_color=1
xdebug.show_local_vars=1

EOF

#use this command for the next two operations: replaces abc with XYZ
#sed -i -e 's/abc/XYZ/g' /tmp/file.txt
#Open the /etc/php5/fpm/php.ini file and change the cgi.fix_pathinfo from 1 to 0 and un comment it.
sudo sed -i -e 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php5/fpm/php.ini
sudo sed -i -e 's/display_errors = Off/display_errors = On/g' /etc/php5/fpm/php.ini

#Open this /etc/php5/fpm/pool.d/www.conf file and change the listen line from listen 127.0.0.1:9000 to /var/run/php5-fpm.sock
sudo sed -i -e 's/listen = 127.0.0.1:9000/listen = \/var\/run\/php5-fpm.sock/g' /etc/php5/fpm/pool.d/www.conf

#Install PHPMyadmin & provide defaults for the prompts
#sudo apt-get -q -y install -y phpmyadmin
# echo 'phpmyadmin phpmyadmin/dbconfig-install boolean true' | debconf-set-selections
# echo 'phpmyadmin phpmyadmin/app-password-confirm password root' | debconf-set-selections
# echo 'phpmyadmin phpmyadmin/mysql/admin-pass password root' | debconf-set-selections
# echo 'phpmyadmin phpmyadmin/mysql/app-pass password root' | debconf-set-selections
# echo 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2' | debconf-set-selections

echo "Setting up shared folders with vagrant: mapping it the the my webroot folder"
sudo rm -rf /usr/share/nginx/www
sudo ln -sf /vagrant /usr/share/nginx/www
echo "<?php phpinfo(); ?>" >  /vagrant/index.php

echo "Setting up Nginx default vhost in sites-availible for PHP"
sudo chmod 777 /etc/nginx/sites-available/default
sudo curl https://raw.github.com/peb7268/vagrant/master/node-nginx-php/sites-availible/default > /etc/nginx/sites-available/default

#Setup Node (untested segment)
echo "============ Installing Node Compiler Deps ===================================="
sudo apt-get install -y build-essential g++

# node settings
NODE_VERSION=0.10.22
NODE_SOURCE=http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.gz

echo "============ Installing Node.js version $NODE_VERSION ========================="
echo "Downloading node source from $NODE_SOURCE"

cd /usr/src
wget --quiet $NODE_SOURCE
tar xf node-v$NODE_VERSION.tar.gz
cd node-v$NODE_VERSION

# configure
./configure --prefix=/opt/node/$NODE_VERSION

# make and install
make
make install

# create node application links
ln -sf /opt/node/$NODE_VERSION/bin/node /usr/bin/node
ln -sf /opt/node/$NODE_VERSION/bin/npm /usr/bin/npm

#add node to the path
echo "export PATH='$HOME:/opt/node/$NODE_VERSION/bin/:$PATH'" >> /home/vagrant/.profile

#Install Package Managers & a few packages
echo "installing bower"
sudo npm install -g bower
sudo npm install -g yo
sudo npm install -g grunt-cli

#Install other packages
sudo npm install -g testem

#Testing if a bin exists
#command -v php >/dev/null 2>&1 || {
#	echo "php not found"
#}
echo "installing composer"
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Install PHPUnit
sudo pear upgrade-all
sudo pear config-set auto_discover 1
sudo pear install -f --alldeps pear.phpunit.de/PHPUnit

#configuring .bashrc
cat << EOBRC | sudo tee -a ~/.bashrc

alias reload='source ~/.bashrc'
alias nginxdir='cd /etc/nginx ~/.bashrc'
alias qngx='sudo service nginx stop'
alias sngx='sudo service nginx start'
alias www='cd /usr/share/nginx/www/'
CLICOLOR=1

EOBRC

#configure vim
cat << EOS | sudo tee -a ~/.vimrc

"Vim Settings
syntax enable
set background=dark
let g:solarized_termcolors=256
colorscheme solarized
set number
set incsearch
set hlsearch
set ignorecase
set wildmenu
set wildmenu                    " show list instead of just completing
set wildmode=list:longest,full  " command <Tab> completion, list matches, then longest common part, then all
set foldenable                  " auto fold code
set autoindent
set shiftwidth=4
set tabstop=4
set softtabstop=4
filetype plugin indent on
set pastetoggle=<F2>

EOS

#Install RVM
curl -L https://get.rvm.io | bash -s stable
source /home/vagrant/.rvm/scripts/rvm
rvm install 2.0.0
rvm install 1.9.3
rvm --default use 1.9.3
gem install bundler
sudo curl https://raw.github.com/peb7268/vagrant/master/node-nginx-php/Gemfile > Gemfile
bundle install

# ensure we have services setup
echo "==> Checking service configurations";
if [ ! -e /etc/init/nginx.conf ]
then
	echo "==> Installing nginx service";
fi

#Restart Nginx & PHP-FPM
sudo service nginx restart
sudo service php5-fpm restart
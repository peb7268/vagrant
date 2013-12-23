#Set the PROJECT_NAME in the vagrant file and in the install.sh script

# Run artisan migrate to setup the database and schema, then seed it
#php artisan migrate --env=development
#php artisan db:seed --env=development

#Restart apache: sudo service apache2 restart
#start redis as a bg daemon: path/to/bin/redis-server&


######### In your root dir ( Not in vagrant ) #######################################

#Make the storage dir
#mkdir -p storage/views storage/cache storage/logs
#sudo chmod -R 777 storage/

#Make a host file in sites-availible that has a server name dev.php.com
#symlink it in sites-enabled sudo ln -s ../sites-availible/dev.php.com dev.php.com

#make your db
#mysql -uroot -p
#create database intengo;
#create database intengo_dev;
#Create / Assign a user
#grant all on intengo.* to root@localhost;
#seet the user's pw
#set password for root@localhost = password('');

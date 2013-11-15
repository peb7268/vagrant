#PHP Nginx Mysql installation instructions
This article covers how to install a Nginx, PHP, MySql (LEMP) Stack on **Ubuntu 12.04.1 LTS** using Vagrant.

#Setting up the sylinked directories for vagrant
sudo rm -rf /usr/share/nginx/www
sudo ln -sf /vagrant /usr/share/nginx/www

Line 1 removes the default nginx webroot directory and its' contents. The second line says that anything that goes in the vagrant directory ( aka your project root ) should be placed in the webroot. Since you deleted the webroot your webroot just becomes a symlink. Thus, anything you do in your editor will be mirrored straiht into your VM webroot.

##Caveats
* If you do not run the mysql-server install wizard it wont setup the php.ini in the fpm directory.
* When doing a wget or curl and then piping that value into a file, make sure you have write permissions on that file. Otherwise, the script could easily fail and just not tell you.

#Getting port 80 to point to 8080 on your local machine
This lets you go to localhost instead of localhost:8080.
To do this we just use the ipfw utility on the mac like so:

sudo ipfw add 100 fwd 127.0.0.1,8080 tcp from any to me 80
sudo ipfw add 101 fwd 127.0.0.1,8443 tcp from any to me 443

to see a list of all the ipfw rules you can use ipfw list
to remove all of the rules you can do ipfw -f flush
alternatively, you can remove 1 entry by typing sudo ipfw delete <record_number>
#PHP Nginx Mysql installation instructions
If you do not run the mysql-server install wizard it wont setup the php.ini in the fpm directory.


#Setting up the sylinked directories for vagrant
sudo rm -rf /usr/share/nginx/www
sudo ln -sf /vagrant /usr/share/nginx/www

Line 1 removes the default nginx webroot directory and its' contents. The second line says that anything that goes in the vagrant directory ( aka your project root ) should be placed in the webroot. Since you deleted the webroot your webroot just becomes a symlink. Thus, anything you do in your editor will be mirrored straiht into your VM webroot.
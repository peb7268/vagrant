#!/usr/bin/env bash
PROJECT_NAME=intengodev

#Ensure the proper permissions are set for certain laravel dirs
echo "Setting permissions for $PROJECT_NAME"
sudo chmod -R a+rw $PROJECT_NAME/public/packages
sudo chmod -R a+rw $PROJECT_NAME/app/config/packages
sudo chmod -R a+rw $PROJECT_NAME/app/storage
echo "Permissions Set for $PROJECT_NAME"

#echo '== Adding entries to local mac firewall (ipfw) ================================='
#sudo ipfw flush
sudo ipfw add 100 fwd 127.0.0.1,8081 tcp from any to me 80

echo "== Starting a redis server instance ============================="
redis-server&

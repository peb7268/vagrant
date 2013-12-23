#!/usr/bin/env bash
PROJECT_NAME=test_project

echo 'Setting permissions for $PROJECT_NAME'

#Ensure the proper permissions are set
# Make some laravel directories writable
sudo chmod -R a+rw $PROJECT_NAME/public/packages
sudo chmod -R a+rw $PROJECT_NAME/app/config/packages
sudo chmod -R a+rw $PROJECT_NAME/app/storage

echo 'Permissions Set for $PROJECT_NAME'
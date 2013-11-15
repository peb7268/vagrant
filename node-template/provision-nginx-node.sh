#!/bin/bash

# node settings
NODE_VERSION=0.10.10
NODE_SOURCE=http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.gz

# nginx settings
NGINX_VERSION=1.4.1
NGINX_SOURCE=http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz

# ensure we have all the required packages to install
echo "==> Checking  Dependencies"
apt-get -y install git libpcre3 libpcre3-dev libpcrecpp0 libssl-dev zlib1g-dev > /dev/null
apt-get -y upgrade > /dev/null

# if we don't have the latest node version, then install
echo "==> Checking Node version $NODE_VERSION installed";
if [ ! -e /opt/node/$NODE_VERSION ]
then
	echo "==> Installing Node.js version $NODE_VERSION"
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
fi

# create node application links
ln -sf /opt/node/$NODE_VERSION/bin/node /usr/bin/node
ln -sf /opt/node/$NODE_VERSION/bin/npm /usr/bin/npm

# if we don't have nginx install, then install
echo "==> Checking Nginx version $NGINX_VERSION installed"
if [ ! -e /opt/nginx-$NGINX_VERSION ]
then
	echo "==> Installing Nginx $NGINX_VERSION";
	echo "Downloading nginx source from $NGINX_SOURCE";

	cd /usr/src
	wget --quiet http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz
	tar xf nginx-$NGINX_VERSION.tar.gz
	cd nginx-$NGINX_VERSION

	# configure nginx
	./configure --with-pcre --with-http_ssl_module --with-http_spdy_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_stub_status_module --prefix=/opt/nginx-$NGINX_VERSION

	# make nginx and install
	make
	make install
fi

# create the appropriate nginx links
ln -sf /opt/nginx-$NGINX_VERSION /opt/nginx

# ensure we have services setup
echo "==> Checking service configurations";
if [ ! -e /etc/init/nginx.conf ]
then
	echo "==> Installing nginx service";
fi
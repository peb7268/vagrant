#http://ariejan.net/2011/10/24/installing-node-js-and-npm-on-ubuntu-debian/
#https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager

class node {

	Exec { "Install Node":
		command => "/bin/sh -c 'cd /usr/local/bin; git clone https://github.com/joyent/node.git; cd node; sudo ./configure; sudo make; sudo make install;'"
	}

	Exec { "install npm":
		command => "/bin/sh -c 'cd /usr/local/bin; curl https://npmjs.org/install.sh | sudo sh;'",
		require => [Exec['Install Node']]
	}
}
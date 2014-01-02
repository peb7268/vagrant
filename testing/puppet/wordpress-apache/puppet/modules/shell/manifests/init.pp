class shell {
	exec { "artisan alias":
		command => "/bin/echo -e alias \"artisan='php artisan'\" >> /home/vagrant/.bashrc"
	}
	exec { "app alias":
		command => "/bin/echo -e alias \"app='cd /vagrant/www/'\" >> /home/vagrant/.bashrc"
	}
	exec { "reload alias":
		command => "/bin/echo -e alias \"reload='source ~/.bashrc'\" >> /home/vagrant/.bashrc"
	}
}
class wordpress {
	$project_name = 'my_cool_wp_project'
	$mysqlPassword = 'root'

	exec { "pull in the latest version of WP":
		command => "git clone https://github.com/WordPress/WordPress.git .",
		require => Package['git-core']
	}

	#create database `my_cool_wp_project`;
	exec { "make the wp database":
		unless => "/usr/bin/mysql -uroot -p$mysqlPassword $project_name",
        command => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'create database `$project_name`;'",
        require => [Service["mysql"], Exec["set-mysql-password"]]
	}

	exec { "set-mysql-password":
        onlyif => "mysqladmin -uroot -p$mysqlPassword status",
        command => "mysqladmin -uroot -proot password $mysqlPassword",
        require => Service["mysql"],
    }

    exec { "grant-default-db":
        command => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'grant all on `$project_name`.* to `root@localhost`;'",
        require => [Service["mysql"], Exec["make the wp database"]]
    }

	exec { "use the wp-config-sample as the config file":
		command => "mv wp-config-sample.php ./wp-config.php",
		require => [Exec['make the wp database']]
	}

	exec { "set the DB_NAME":
		command => "sed -i 's/database_name_here/some_name/' wp-config.php",
	}

	exec { "set the DB_USER":
		command => "sed -i 's/username_here/some_user/' wp-config.php",
	}

	exec { "set the DB_PASSWORD":
		command => "sed -i 's/password_here/some_pass/' wp-config.php",
	}

	exec { "install wordpress tests":
		#command => "https://github.com/nb/wordpress-tests .",
	}
}
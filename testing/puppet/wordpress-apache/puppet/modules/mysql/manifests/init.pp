class mysql {
    $mysqlPassword = "root"

    package { "mysql-server":
        ensure  => present,
        require => Exec['apt-get update']
    }

    service { "mysql":
        enable => true,
        ensure => running,
        require => Package["mysql-server"],
    }

    # Make sure that any previously setup boxes are gracefully
    # transitioned to the new empty root password.
    exec { "set-mysql-password":
        onlyif => "mysqladmin -uroot -proot status",
        command => "mysqladmin -uroot -proot password $mysqlPassword",
        require => Service["mysql"],
    }

    exec { "create-default-db":
        unless => "/usr/bin/mysql -uroot -p$mysqlPassword intengodev",
        command => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'create database `intengodev`;'",
        require => [Service["mysql"], Exec["set-mysql-password"]]
    }

    exec { "grant-default-db":
        command => "/usr/bin/mysql -uroot -p$mysqlPassword -e 'grant all on `intengodev`.* to `root@localhost`;'",
        require => [Service["mysql"], Exec["create-default-db"]]
    }

}
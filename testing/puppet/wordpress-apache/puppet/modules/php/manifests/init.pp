class php
{
    #All the php specific base packages
    $packages = [
        "php5",
        "php5-cli",
        "php5-mysql",
        "php-pear",
        "php5-dev",
        "php-apc",
        "php5-mcrypt",
        "php5-gd",
        "php5-curl",
        "libapache2-mod-php5",
        "php5-xdebug",
        "php5-memcache",
        "php5-memcached",
        "php5-pgsql",
        "php5-sqlite",
        "libreadline5"
    ]

    package {
        $packages:
            ensure  => latest,
            require => [Exec['apt-get update'], Package['python-software-properties']]
    }
    exec { "Install PHPUnit":
        command => "wget http://phar.phpunit.de/phpunit.phar; chmod +x phpunit.phar; sudo mv phpunit.phar /usr/local/bin/phpunit;",
        require => [Package['libreadline5'], Package['php-pear']],
        timeout => 900
    }

    #sed -i "s/disable_functions = .*/disable_functions = /" /etc/php5/cli/php.ini
    # exec
    # {
    #     "sed -i 's|#|//|' /etc/php5/cli/conf.d/mcrypt.ini":
        #     require => Package['php5'],
    # }

    #Ensure that the apache php.ini and the cli php.ini are installed
    file { "/etc/php5/apache2/php.ini":
            ensure  => present,
            owner   => root, group => root,
            notify  => Service['apache2'],
            #source => "/vagrant/puppet/templates/php.ini",
            content => template('php/php.ini.erb'),
            require => [Package['php5'], Package['apache2']],
    }

    file { "/etc/php5/cli/php.ini":
            ensure  => present,
            owner   => root, group => root,
            notify  => Service['apache2'],
            content => template('php/cli.php.ini.erb'),
            require => [Package['php5']],
    }

    exec { "Remove the disable_functions values from the cli/php.ini":
        command => "sed -i 's/disable_functions = .*/disable_functions = /' /etc/php5/cli/php.ini",
        require => [Package['php5'], Package['apache2']]
    }
}

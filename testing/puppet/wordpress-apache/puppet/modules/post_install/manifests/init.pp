class post_install {
    #Make sure that any requests to localhost entries go to port 8081
    exec { 'sudo ipfw add 100 fwd 127.0.0.1,8081 tcp from any to me 80':
            require => Exec['setup laravel installer'],
    }
}
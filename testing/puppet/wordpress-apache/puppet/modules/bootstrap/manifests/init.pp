#Gets info from facter. To inspec run facter at the command line.
#The variables below are set with facter. To inspect the fully qualified domain name (fqdn) type: facter fqdn
#http://docs.puppetlabs.com/facter/latest/core_facts.html#fqdn

class bootstrap {
    group { "puppet":
        ensure => "present",
    }

    if $virtual == "virtualbox" and $fqdn == '' {
        $fqdn = "localhost"
    }
}
include ntpd
include apachephp
include db
include createdb
include apc
include imagick
include ezfind
include virtualhosts
include firewall
include composer
include prepareezpublish
include motd
include addhosts
include addtostartup

class ntpd {
    package { "ntpdate.x86_64": 
      ensure => installed 
    }
    service { "ntpd":
      ensure => running,
    }
}

class motd {
    file    {'/etc/motd':
      ensure  => file,
      content => template('/tmp/vagrant-puppet/manifests/motd/motd.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '644',
    }
}

class apachephp {
    $neededpackages = [ "httpd", "php", "php-cli", "php-gd" ,"php-mysql", "php-pear", "php-xml", "php-mbstring", "php-pecl-apc", "php-process", "curl.x86_64", "php-intl.x86_64" ]
    package { $neededpackages:
        ensure => present,
    } ~>
    file    {'/etc/httpd/conf.d/01.accept_pathinfo.conf':
      ensure  => file,
      content => template('/tmp/vagrant-puppet/manifests/httpd/01.accept_pathinfo.conf.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '644',
    } ~>
    file    {'/etc/php.d/php.ini':
      ensure  => file,
      content => template('/tmp/vagrant-puppet/manifests/php/php.ini.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '644',
    } 
}

class imagick {
    $neededpackages = [ "ImageMagick", "ImageMagick-devel", "ImageMagick-perl" ]
    package { $neededpackages:
      ensure => installed
    }
    exec    { "update-channels":
      command => "pear update-channels",
      path    => "/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/vagrant/bin",
      require => Package['php-pear'],
      returns => [ 0, 1, '', ' ']
    } ~>
    exec    { "install imagick":
      command => "pecl install imagick",
      path    => "/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/vagrant/bin",
      require => Package['php-pear'],
      returns => [ 0, 1, '', ' ']
    }
}

class db {
    $neededpackages = [ "mysql", "mysql-server"]
    package { $neededpackages:
      ensure => installed
    }
    file    {'/etc/my.cnf':
      ensure  => file,
      content => template('/tmp/vagrant-puppet/manifests/mysql/my.cnf.erb'),
      owner   => 'root',
      mode    => '644',
    }
    service { "mysqld":
      ensure => running,
      hasstatus => true,
      hasrestart => true,
      require => Package["mysql-server"],
      restart => true;
    }
}


class apc {
    $neededpackages = [ "php-devel", "httpd-devel", "pcre-devel.x86_64", "php-pecl-apc.x86_64" ]
    package { $neededpackages:
      ensure => installed
    } ~>
    file    {'/etc/php.d/apc.ini':
      ensure  => file,
      content => template('/tmp/vagrant-puppet/manifests/php/apc.ini.erb'),
    }
}

class createdb {
    exec { "create-ezp-db":
      command => "/usr/bin/mysql -uroot -e \"create database ezp character set utf8; grant all on ezp.* to ezp@localhost identified by 'ezp';\"",
      require => Service["mysqld"],
      returns => [ 0, 1, '', ' ']
    }
}

class ezfind {
    package { "java-1.6.0-openjdk.x86_64":
      ensure => installed
    }
}

class virtualhosts {
    file    {'/etc/httpd/conf.d/02.namevirtualhost.conf':
      ensure  => file,
      content => template('/tmp/vagrant-puppet/manifests/virtualhost/02.namevirtualhost.conf.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '644',
      require => Package["httpd"],
    }
    file    {'/etc/httpd/conf.d/ezp5.conf':
      ensure  => file,
      content => template('/tmp/vagrant-puppet/manifests/virtualhost/ezp5.conf.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '644',
      require => Package["httpd"],
    }
}

class firewall {
    file    {'/etc/sysconfig/iptables':
      ensure  => file,
      content => template('/tmp/vagrant-puppet/manifests/iptables/iptables.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '600',
    }
    service { iptables:
      ensure => running,
      subscribe => File["/etc/sysconfig/iptables"],
    }
}

class composer {
    exec    { "get composer":
      command => "curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin",
      path    => "/usr/local/bin:/usr/bin/",
      require => Package["httpd"],
      returns => [ 0, 1, '', ' ']
    } ~>
    exec    { "link composer":
      command => "/bin/ln -s /usr/local/bin/composer.phar /usr/local/bin/composer.phar",
      path    => "/usr/local/bin:/usr/bin/:/bin",
      returns => [ 0, 1, '', ' ']
    }
}

class prepareezpublish {
    service { 'httpd':
      ensure => running,
      enable => true,
      before => Exec["prepare eZ Publish"],
      require => [File['/etc/httpd/conf.d/01.accept_pathinfo.conf'], File['/etc/httpd/conf.d/ezp5.conf']]
    } ~>
    exec    { "prepare eZ Publish":
      command => "/bin/bash /tmp/vagrant-puppet/manifests/preparezpublish.sh",
      path    => "/usr/local/bin/:/bin/",
      require => Package["httpd", "php", "php-cli", "php-gd" ,"php-mysql", "php-pear", "php-xml", "php-mbstring", "php-pecl-apc", "php-process", "curl.x86_64"]
    } ~>
    exec { "Fix Permissions":
      command => "/bin/chown -R apache:apache /var/www/html/",
      path => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
    }
}

class addhosts {
    file    {'/etc/hosts':
      ensure  => file,
      content => template('/tmp/vagrant-puppet/manifests/hosts/hosts.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '644',
    }
}

class addtostartup {
    exec    { "add httpd to startup":
      command => "/sbin/chkconfig httpd on",
      path    => "/usr/local/bin/:/bin/",
      require => Package["httpd", "php", "php-cli", "php-gd" ,"php-mysql", "php-pear", "php-xml", "php-mbstring", "php-pecl-apc", "php-process", "curl.x86_64"]
    } ~>
    exec    { "add mysql to startup":
      command => "/sbin/chkconfig --add mysqld",
      path    => "/usr/local/bin/:/bin/",
      require => Package["httpd", "php", "php-cli", "php-gd" ,"php-mysql", "php-pear", "php-xml", "php-mbstring", "php-pecl-apc", "php-process", "curl.x86_64"]
    } ~>
    exec    { "add mysql":
      command => "/sbin/chkconfig mysqld on",
      path    => "/usr/local/bin/:/bin/",
      require => Package["httpd", "php", "php-cli", "php-gd" ,"php-mysql", "php-pear", "php-xml", "php-mbstring", "php-pecl-apc", "php-process", "curl.x86_64"]
    }
}

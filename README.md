# vagrant:ezp5:puppet:mysql

Prototype development machine for eZ Publish 5.x, provisioned with Puppet.

## Stack & utilities:

- CentOS 6.4 x64
- Apache 2.2.15
- MySQL 5.1.69
- PHP 5.3.3
- APC 3.1.9
- Xdebug 2.2.3 or not, this is your choice through Vagrantfile setup
- Composer
- Git or not, this is your choice throught Vagrantfile setup
- eZ Publish 5 Community 2013.07

## Requirements:

- Vagrant (http://vagrantup.com)
- VirtualBox (https://www.virtualbox.org/) or VMWare (http://www.vmware.com/)

## Getting started:

- Clone this project to a directory 
- Run `$ vagrant up` from the terminal
- Wait (the first time will take a few minutes, as the base box is downloaded, and required packages are installed for the first time), get some coffee.
- Done! `$ vagrant ssh` to SSH into your newly created machine. The MOTD contains details on the database, hostnames, etc.
- By default Xdebug is enable, if you want to disable it, go to line 55 of Vagrantfile comment it and uncomment line 58. Don't forget to run `$ vagrant up` after

## Environment Details:

```
MySQL:
  default database: ezp
  default db user: ezp
  default db user password: ezp

Apache/httpd: www root: /var/www/html

eZ Publish 5 Project:
  location: /var/www/html/ezpublish5
  hostname: ezp5.dev.vagrant
  admin hostname: admin.ezp5.dev.vagrant
  environment: dev
```

Built @ [cleverti](http://www.cleverti.com) by Pedro Resende
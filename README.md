# puppet-nagios

## Overview

This module provides a full nagios monitoring solution, for setting up both
servers and clients. There can be any number of each, though there is typically
one server and many clients. The main limitation is that all server and client
nodes need to have all of their nagios related puppet configuration on the
same puppetmaster.

The server part is still very Red Hat Enterprise Linux specific. The client
part is much more generic and has been tested on both RHEL and Gentoo.

## Requirements

* Stored configurations enabled on the puppetmaster (mandatory)
* `apache_httpd` and `php` modules used for the nagios server node (optional)

The `apache_httpd` and `php` modules are required for the server part, though
optionally since it's also possible to use an existing non-puppet managed web
server or different module modules. For a new empty node, configuring it as a
nagios server will be much quicker if those modules can be used.

Stored configurations are essential on the puppetmaster for the module to work
at all, since it relies on having all nodes create their own exported nagios
host and service resources, which the nagios server node then realizes to
build its configuration.

The plugin packages used for RHEL with selinux enabled should have the
libexecdir directory properly set to `/usr/libexec` in order to avoid selinux
denials. Such packages can be found on http://dl.marmotte.net/rpms/

When SELinux is enforcing, the `selinux::audit2allow` definition is required
to allow some basic nagios/nrpe accesses, though it can also be disabled.

## Sample Usage

Nagios server instance (node specific, typically inside a node section) :

    class { 'nagios::server':
      apache_httpd_ssl             => false,
      apache_httpd_conf_content    => 'puppet:///modules/my/nagios-httpd.conf',
      apache_httpd_htpasswd_source => 'puppet:///modules/my/htpasswd',
      cgi_authorized_for_system_information        => '*',
      cgi_authorized_for_configuration_information => '*',
      cgi_authorized_for_system_commands           => '*',
      cgi_authorized_for_all_services              => '*',
      cgi_authorized_for_all_hosts                 => '*',
      cgi_authorized_for_all_service_commands      => '*',
      cgi_authorized_for_all_host_commands         => '*',
      cgi_default_statusmap_layout                 => '3',
    }

Nagios client instances (typically from `site.pp`) :

    class { 'nagios::client':
      nrpe_allowed_hosts => '127.0.0.1,192.168.1.1',
    }

Nagios client specific overrides. See `client.pp` and `check/*.pp` for all of
the variables which can be manipulated this way. The following :

    nagios::client::config { 'host_address': value => $ipaddress_eth2 }

Will result in having `$::nagios_host_name` get `$ipaddress_eth2` as its value
for the entire configuration of the client where it is applied.

Nagios client check override configuration examples :

    nagios::client::config { 'check_ram_ensure': value => 'absent' }
    nagios::client::config { 'check_cpu_args': value => '-w 50 -c 20' }

Configuring a default check (must be done from a scope where `nagios::client`
can inherit it)  :

    Nagios::Check::Swap { ensure => absent }
    if $::domain == 'example.com' {
      Nagios::Check::Cpu { notification_period => 'workhours' }
    }

To enable nagiosgraph on the server :

    class { 'nagios::nagiosgraph':
      # This is the default
      perflog => '/var/log/nagios/service_perfdata.log',
      # To enable the mouseover graphs
      nagios_service_action_url => '/nagiosgraph/cgi-bin/show.cgi?host=$HOSTNAME$&service=$SERVICEDESC$\' onMouseOver=\'showGraphPopup(this)\' onMouseOut=\'hideGraphPopup()\' rel=\'/nagiosgraph/cgi-bin/showgraph.cgi?host=$HOSTNAME$&service=$SERVICEDESC$',
      ssi => true,
    }
    # This is what needs to be changed/added for nagios::server
    class { 'nagios::server':
      process_performance_data => '1',
      service_perfdata_file    => '/var/log/nagios/service_perfdata.log',
      service_perfdata_file_template => '$LASTSERVICECHECK$||$HOSTNAME$||$SERVICEDESC$||$SERVICEOUTPUT$||$SERVICEPERFDATA$',
      service_perfdata_file_processing_interval => '30',
      service_perfdata_file_processing_command => 'process-service-perfdata-nagiosgraph',
    }

To enable nagiosgraph for the client's services in the server web interface :

    class { 'nagios::client':
      service_use => 'generic-service,nagiosgraph-service',
    }

## Hints

Debug any startup or configuration problems on the server with :

    nagios -v /etc/nagios/nagios.cfg

A lot can be configured semi-dynamically for `nagios::client` (ideally using
hiera's automatic class parameter lookup) :

    class { 'nagios::client':
      host_notification_period => $::domain ? {
        /\.dev$/ => 'workhours',
        default  => '24x7',
      }
      # You will need to use the type "nagios_hostgroup" on the server for
      # all of the possible domain values to create the hostgroups.
      host_hostgroups => $::domain,
    }

## Notes

Client overrides should be done in this order :
* For all services on some nodes : Using `nagios::client service_*` parameters
* For all services on a node : Using the `nagios::client host_*` parameters
* For specific services on all nodes : Using `Nagios::Check::Foo { paramname => 'value' }` (the scope must be the same or lower than where `nagios::client` is called from)
* For specific services on a node : Using `nagios::client::config { 'check_*': value => 'foo' }` overrides

Note : `nagios::client::config` can also be used to override just about
anything, though you must take into account that since it's done using custom
facts, you'll need two puppet runs on the client node then one on the server
node for the change to be applied : One for the fact to be created, then
another for the client configuration to take the new fact into account, then
the server run to update the nagios configuration. This might take a little
while depending on how often puppet is run on the nodes.

## mysql_health

The mysql_health part is more recent than the rest, and :
* Relies on using automatic hiera class parameter lookups.
* Requires the puppetlabs-stdlib module because it uses getvar().

You will need to create the MySQL user on your servers, allowed for localhost
since we use nrpe for execution. Example :

    # This could go in site.pp, the fact is true only if mysqld is found
    if $::nagios_mysqld == 'true' {
      database_user { 'nagios@localhost':
        ensure        => present,
        password_hash => mysql_password('mysupersecretpassword'),
        provider      => 'mysql',
      }
    }

    # In hieradata
    nagios::check::mysql_health::args: '--username nagios --password mysupersecretpassword'

The single mysql_health script has many different 'modes', which are all
enabled by default. Because hyphens shouldn't be used in puppet variable names,
we use underscores instead in their names.

You can either selectively disable some :

    # Disable some checks (modes)
    nagios::check::mysql_health::modes_disabled:
      - 'slave_io_running'
      - 'slave_lag'
      - 'slave_sql_running'

Or selectively enable some :

    # Enable only the following checks (modes)
    nagios::check::mysql_health::modes_enabled:
      - 'connection_time'
      - 'open_files'
      - 'uptime'

Then for each mode, you can also pass some arguments, typically to change the
warning and critical values as needed :

    # Tweak some check values
    nagios::check::mysql_health::args_connection_time: '--warning 5 --critical 10'


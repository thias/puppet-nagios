# puppet-nagios

## Overview

This module provides a full nagios monitoring solution, for setting up both
servers and clients. There can be any number of each, though there is typically
one server and many clients. The main limitation is that all server and client
nodes need to have all of their nagios related puppet configuration on the
same puppetmaster.

The server part is still very Red Hat Enterprise Linux specific. The client
part is much more generic and has been tested on both RHEL and Gentoo.

Please note that this module is not for the faint of heart. Even I (the author)
have my head hurt each time I have to make modificiations to it... but it is
worth it, as it allows having monitoring automatically enabled by default
on all nodes as well as for all standard services detected on them.

## Upgrading

Version 2 of the module has updated all default checks to become classes, in
order to work better with hiera's class parameters automatic lookup. The
drawback is that overrides which were set from manifests possibly need to be
moved to hieradata.

When upgrading from version 1, if you see checks changing arguments or getting
added or removed, look at the check's parameters and migrate your exsting
overrides, typically :

```yaml
# Override the critical value for check foo
nagios::check::foo::args: '-c 10%'
# Disable the bar check completely
nagios::check::bar::ensure: 'absent'
```

## Requirements

* Stored configurations enabled on the puppetmaster (mandatory)
* `apache_httpd` and `php` modules used for the nagios server node (optional)

The `apache_httpd` and `php` modules are required for the server part, though
optionally since it is also possible to use an existing non-puppet managed web
server or different puppet modules. For a new empty node, configuring it as a
nagios server will be much quicker if those modules can be used.

Stored configurations are essential on the puppetmaster for the module to work
at all, since it relies on having all nodes create their own exported nagios
host and service resources, which the nagios server node then realizes to
build its configuration.

For RHEL, any packages which might be required but are not part of the
official repositories or EPEL can be found on http://dl.marmotte.net/rpms/

When SELinux is enforcing, the `selinux::audit2allow` definition is required
to allow some basic nagios/nrpe accesses, though it can also be disabled.

## Sample Usage

Nagios server instance (node specific, typically inside a node section) :

```puppet
class { '::nagios::server':
  apache_httpd_ssl             => false,
  apache_httpd_conf_content    => template('my/httpd-nagios.conf.erb'),
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
```

Nagios client instances (typically from `site.pp`) :

```puppet
class { '::nagios::client':
  nrpe_allowed_hosts => '127.0.0.1,192.168.1.1',
}
```

Nagios client specific overrides. See `client.pp` and `check/*.pp` for all of
the variables which can be manipulated this way. The following :

```puppet
nagios::client::config { 'host_address': value => $::ipaddress_eth2 }
```

Will result in having `$::nagios_host_name` get `$ipaddress_eth2` as its value
for the entire configuration of the client where it is applied.

Nagios client check override configuration examples :

```puppet
nagios::client::config { 'check_ram_ensure': value => 'absent' }
nagios::client::config { 'check_cpu_args': value => '-w 50 -c 20' }
```

Configuring a default check (must be done from a scope where `nagios::client`
can inherit it)  :

```puppet
Nagios::Check::Swap { ensure => 'absent' }
if $::domain == 'example.com' {
  Nagios::Check::Cpu { notification_period => 'workhours' }
}
```

To enable nagiosgraph on the server :

```puppet
class { '::nagios::nagiosgraph':
  # This is the default
  perflog => '/var/log/nagios/service_perfdata.log',
  # To enable the mouseover graphs
  nagios_service_action_url => '/nagiosgraph/cgi-bin/show.cgi?host=$HOSTNAME$&service=$SERVICEDESC$\' onMouseOver=\'showGraphPopup(this)\' onMouseOut=\'hideGraphPopup()\' rel=\'/nagiosgraph/cgi-bin/showgraph.cgi?host=$HOSTNAME$&service=$SERVICEDESC$',
  ssi => true,
}
# This is what needs to be changed/added for nagios::server
class { '::nagios::server':
  process_performance_data => '1',
  service_perfdata_file    => '/var/log/nagios/service_perfdata.log',
  service_perfdata_file_template => '$LASTSERVICECHECK$||$HOSTNAME$||$SERVICEDESC$||$SERVICEOUTPUT$||$SERVICEPERFDATA$',
  service_perfdata_file_processing_interval => '30',
  service_perfdata_file_processing_command => 'process-service-perfdata-nagiosgraph',
}
```

To enable nagiosgraph for the client's services in the server web interface :

```puppet
class { '::nagios::client':
  service_use => 'generic-service,nagiosgraph-service',
}

To override the parameters of a default template using hiera :

```yaml
---
# Remove default warning notifications for services
nagios::server::template_generic_service:
  notification_options: 'u,c,r'
```

## Hints

Debug any startup or configuration problems on the server with :

```bash
nagios -v /etc/nagios/nagios.cfg
```

A lot can be configured semi-dynamically for `nagios::client` (ideally using
hiera's automatic class parameter lookup) :

```puppet
class { '::nagios::client':
  host_notification_period => $::domain ? {
    /\.dev$/ => 'workhours',
    default  => '24x7',
  }
  # You will need to use the type "nagios_hostgroup" on the server for
  # all of the possible domain values to create the hostgroups.
  host_hostgroups => $::domain,
}
```

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

## MySQL

For the `mysql_health` based checks to work, you will need to create the MySQL
user on your servers, allowed for localhost since we use nrpe for execution.
Example :

```puppet
# This could go in site.pp, the fact is present only if mysqld is found
if $::nagios_mysqld {
  mysql_user { 'nagios@localhost':
    ensure        => 'present',
    password_hash => mysql_password('mysupersecretpassword'),
  }
  mysql_grant { 'nagios@localhost/*.*':
    user       => 'nagios@localhost',
    table      => '*.*',
    privileges => [ 'REPLICATION CLIENT' ],
    require    => Mysql_user['nagios@localhost'],
  }
}
```

```yaml
# In hieradata
nagios::check::mysql_health::args: '--username nagios --password mysupersecretpassword'
```

The single `mysql_health` script has many different 'modes', which are all
enabled by default. Because hyphens shouldn't be used in puppet variable names,
we use underscores instead in their names.

You can either selectively disable some :

```yaml
# Disable some checks (modes)
nagios::check::mysql_health::modes_disabled:
  - 'slave_io_running'
  - 'slave_lag'
  - 'slave_sql_running'
```

Or selectively enable some :

```yaml
# Enable only the following checks (modes)
nagios::check::mysql_health::modes_enabled:
  - 'connection_time'
  - 'open_files'
  - 'uptime'
```

Then for each mode, you can also pass some arguments, typically to change the
warning and critical values as needed :

```yaml
# Tweak some check values
nagios::check::mysql_health::args_connection_time: '--warning 5 --critical 10'
```

## PostgreSQL

The `postgres` checks are very similar to the `mysql_health` ones. The single
`postgres` script has many 'actions' ('modes'), which are enabled by default.

You can either selectively disable some :

```yaml
# Disable some checks (modes)
nagios::check::postgres::modes_disabled:
  - 'new_version_pg'
  - 'new_version_tnm'
  - 'pgb_pool_cl_active'
```

Or selectively enable some :

```yaml
# Enable only the following checks (modes)
nagios::check::postgres::modes_enabled:
  - 'locks'
  - 'logfile'
  - 'query_time'
```

Then for each mode, you can also pass some arguments, typically to change the
warning and critical values as needed :

```yaml
# Tweak some check values
nagios::check::postgres::args_query_time: '--warning=20s --critical=2m'
```

It is also possible to specify some custom query checks :

```yaml
nagios::check::postgres::custom_queries:
  custom_query_1:
    query: 'SELECT SUBSTRING(version(), 12, 5)'
    valtype: 'string'
    warning: '9.4.4'
  custom_query_2:
    query: "SELECT SUBSTRING(version(), 12, 1) AS result"
    warning: 9
    valtype: 'integer'
    reverse: true
```

For more info please refer to the `check_postgres` nagios plugin
documentation : https://bucardo.org/check_postgres/check_postgres.pl.html

## MongoDB

The `mongodb` checks are very similar to the `mysql_health` ones. The single
`mongodb` script has many 'actions' ('modes'), which are enabled by default.
They may be enabled and disabled individually, or in groups of relevant
checks, for instance all replication checks at once.

You will need to create the monitoring user and set the information :

```yaml
nagios::check::mongodb::user: 'nagios'
nagios::check::mongodb::pass: 'mysupersecretpassword'
```

```
db.createUser(
  {
    user: "nagios",
    pwd: "mysupersecretpassword",
    roles:
      [
        "readAnyDatabase",
        "clusterMonitor",
        { role: "readWrite", db: "local" },
        { role: "readWrite", db: "nagios" }
      ]
   }
)
```

You can completely disable MongoDB monitoring for some nodes :

```yaml
nagios::check::mongodb::ensure: 'absent'
```

You can selectively disable some :

```yaml
# Disable some checks (modes)
nagios::check::mongodb::modes_disabled:
  - 'oplog'
  - 'queries_per_second'
  - 'queues'
```

Or selectively enable some :

```yaml
# Enable only the following checks (modes)
nagios::check::mongodb::modes_enabled:
  - 'connect'
  - 'page_faults'
```

Or disable entire groups of non-relevant checks :

```yaml
# Disable non relevant checks
nagios::check::mongodb::mmapv1: false
nagios::check::mongodb::v2: false
nagios::check::mongodb::replication: false
nagios::check::mongodb::sharding: false
```

For an arbiter, you can disable all non-relevant checks :

```yaml
nagios::check::mongodb::arbiter: true
```

Then for each mode, you can also pass some arguments, typically to change the
warning and critical values as needed :

```yaml
# Tweak some check values
nagios::check::mongodb::args_connect: '-W 2 -C 4'
nagios::check::mongodb::args_connections: '-W 70 -C 80'
nagios::check::mongodb::args_memory: '-W 8 -C 16'
nagios::check::mongodb::args_opcounters: '-W 10000 -C 50000'
nagios::check::mongodb::args_replication_lag: '-W 15 -C 30'
```

For more info please refer to the `nagios-plugin-mongodb` documentation :
https://github.com/mzupan/nagios-plugin-mongodb

## Slack messaging integration

If you want to have your nagios notifications in Slack, enable the slack plugin
by setting `$plugin_slack` parameter to `true`.

Additional parameters:
* `$plugin_slack_webhost` (mandatory): an IP or FQDN for the host you installed nagios web interface
* `$plugin_slack_webhook` (mandatory): Slack Web Hook url (grab it from Integration page at Slack Web Hook setup instruction section)
* `$plugin_slack_channel` (default: '#alerts'): the channel where the bot will post in
* `$plugin_slack_botname` (default: 'nagios'): the bot name

Sample Slack contact and commands configuration:

```puppet
  nagios_contact { 'slack':
    alias                         => 'Slack',
    service_notification_period   => '24x7',
    host_notification_period      => '24x7',
    service_notification_options  => 'w,u,c,r',
    host_notification_options     => 'd,r',
    service_notification_commands => 'notify-service-by-slack',
    host_notification_commands    => 'notify-host-by-slack',
  }
  nagios_command { 'notify-service-by-slack':
    command_line => '$USER1$/slack_nagios > /tmp/slack.log 2>&1',
  }
  nagios_command { 'notify-host-by-slack':
    command_line => '$USER1$/slack_nagios > /tmp/slack.log 2>&1',
  }
```

Then the `slack` contact should be added to the `$admins_members` parameter of
the main `nagios::server` class.

## Removing hosts

If you decommission a Nagios-monitored host a couple of manual steps are
required to clean up.

```bash
# On the Puppet Master
puppet node deactivate <my_host>

# On the Nagios server
puppet agent -t
service nagios reload|restart
```

See [Issue #21](https://github.com/thias/puppet-nagios/issues/21) on why the
service restart is required.


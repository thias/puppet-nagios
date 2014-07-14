class nagios::nagiosgraph (
  # The 'nagios_command' and 'nagios_service' we add
  $nagios_command_name       = 'process-service-perfdata-nagiosgraph',
  $nagios_command_line       = '/usr/libexec/nagiosgraph/insert.pl',
  $nagios_service_name       = 'nagiosgraph-service',
  $nagios_service_action_url = '/nagiosgraph/cgi-bin/show.cgi?host=$HOSTNAME$&service=$SERVICEDESC$',
  # The apache config snippet, more useful as a template when using a custom
  $apache_httpd              = true,
  $apache_httpd_conf_content = undef,
  $apache_httpd_conf_source  = undef,
  $apache_httpd_conf_file    = '/etc/httpd/conf.d/nagiosgraph.conf',
  # Used in the nagiosgraph.conf template
  $perflog     = '/var/log/nagios/service_perfdata.log',
  $plotasarea  = 'idle,data;system,data;user,data;nice,data',
  $timeall     = 'day,week,month,year',
  $timehost    = 'day,week,month,year',
  $timeservice = 'day,week,month,year',
  $timegroup   = 'day,week,month,year',
  # Other
  $selinux = true,
  $ssi     = false,
  $gif     = false
) {

  # Get the same value as the server (hack-ish, used in the default template)
  if $::nagios::server::apache_allowed_from != '' {
    $apache_allowed_from = $::nagios::server::apache_allowed_from
  } else {
    $apache_allowed_from = []
  }

  # Set a default content template if no content/source is specified
  if $apache_httpd_conf_source == '' {
    if $apache_httpd_conf_content == '' {
      $apache_httpd_conf_content_final = template('nagios/apache_httpd/httpd-nagiosgraph.conf.erb')
    } else {
      $apache_httpd_conf_content_final = $apache_httpd_conf_content
    }
  }

  package { 'nagiosgraph': ensure => installed }

  nagios_command { $nagios_command_name:
    command_line => $nagios_command_line,
    notify       => Service['nagios'],
  }
  # Service template, "use" it from graphed services to create web links
  nagios_service { $nagios_service_name:
    action_url => $nagios_service_action_url,
    register   => '0',
    notify     => Service['nagios'],
  }

  file { '/etc/nagiosgraph/nagiosgraph.conf':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('nagios/nagiosgraph/nagiosgraph.conf.erb'),
    require => Package['nagiosgraph'],
  }

  if $apache_httpd {
    file { $apache_httpd_conf_file:
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => $apache_httpd_conf_content_final,
      source  => $apache_httpd_conf_source,
      notify  => Service['httpd'],
      require => Package['nagiosgraph'],
    }
  }

  # With selinux, adjustements are needed for nagiosgraph
  if $selinux and $::selinux_enforced {
    selinux::audit2allow { 'nagiosgraph':
      source => "puppet:///modules/${module_name}/messages.nagiosgraph",
    }
  }

  # Server-Side Include nagios CGI snippet for mouseover js code
  if $ssi {
    file { '/usr/share/nagios/html/ssi/common-header.ssi':
      ensure => link,
      target => '/usr/share/nagiosgraph/examples/nagiosgraph.ssi',
      require => Package['nagios'],
    }
  }

  # Overwrite the original action image, as suggested in the INSTALL
  if $gif {
    file { '/usr/share/nagios/html/images/action.gif':
      ensure  => link,
      target  => '/usr/share/nagiosgraph/examples/graph.gif',
      require => Package['nagios'],
    }
  }

}


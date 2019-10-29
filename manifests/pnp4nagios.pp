# pnp4nagios class
#
class nagios::pnp4nagios (
  $nagios_command_name       = 'process-service-perfdata-pnp4nagios',
  $nagios_command_line       = '/usr/libexec/pnp4nagios/process_perfdata.pl --bulk',
  $nagios_service_name       = 'pnp4nagios-service',
  $nagios_service_action_url = '/pnp4nagios/index.php/graph?host=$HOSTNAME$&srv=$SERVICEDESC$',
  $perflog                   = '/var/log/pnp4nagios/service-perfdata',
  # The apache config snippet
  $apache_httpd              = true,
  $apache_httpd_conf_content = undef,
  $apache_httpd_conf_source  = undef,
  $apache_httpd_conf_file    = '/etc/httpd/conf.d/pnp4nagios.conf',
  # Other
  Boolean $selinux           = true,
  $ssi                       = false
) {

  # Get the same value as the server (hack-ish, used in the default template)
  if $::nagios::server::apache_allowed_from != '' {
    $apache_allowed_from = $::nagios::server::apache_allowed_from
  } else {
    $apache_allowed_from = []
  }

  # Set a default content template if no content/source is specified
  if $apache_httpd_conf_source == undef {
    if $apache_httpd_conf_content == undef {
      $apache_httpd_conf_content_final = template("${module_name}/apache_httpd/httpd-pnp4nagios.conf.erb")
    } else {
      $apache_httpd_conf_content_final = $apache_httpd_conf_content
    }
  }

  package { 'pnp4nagios': ensure => 'installed' }
  ensure_packages('perl(Time::HiRes)')

  nagios_command { $nagios_command_name:
    command_line => "${nagios_command_line} ${perflog}",
    notify       => Service['nagios'],
  }

  # Service template, "use" it from graphed services to create web links
  nagios_service { $nagios_service_name:
    action_url => $nagios_service_action_url,
    register   => '0',
    notify     => Service['nagios'],
  }

  if $apache_httpd {
    file { $apache_httpd_conf_file:
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => $apache_httpd_conf_content_final,
      source  => $apache_httpd_conf_source,
      notify  => Service['httpd'],
      require => Package['pnp4nagios'],
    }
  }

  # With selinux, adjustements are needed for pnp4nagios
  if $selinux and $::selinux_enforced {
    selinux::audit2allow { 'pnp4nagios':
      source => "puppet:///modules/${module_name}/messages.pnp4nagios",
    }
  }

  # Server-Side Include nagios CGI snippet for mouseover js code
  # https://docs.pnp4nagios.org/pnp-0.6/webfe
  # Content from /usr/share/doc/pnp4nagios-0.6.25/contrib/ssi/status-header.ssi
  if $ssi {
    file { '/usr/share/nagios/html/ssi/common-header.ssi':
      ensure  => 'present',
      source  => "puppet:///modules/${module_name}/pnp4nagios/common-header.ssi",
      require => Package['nagios'],
    }
  }
}


define nagios::check::nginx (
  $ensure = undef,
  $args   = undef,
) {

  # Generic overrides
  if $::nagios_check_nginx_check_period != undef {
    Nagios_service { check_period => $::nagios_check_nginx_check_period }
  }
  if $::nagios_check_nginx_notification_period != undef {
    Nagios_service { notification_period => $::nagios_check_nginx_notification_period }
  }

  # Service specific overrides
  if $::nagios_check_nginx_args != undef {
    $fullargs = $::nagios_check_nginx_args
  } else {
    $fullargs = $args
  }

  # Needs "plugin_nginx => true" on nagios::server to get the check script

  nagios::service { "check_nginx_${title}":
    ensure              => $ensure,
    check_command       => "check_nginx!${fullargs}",
    service_description => 'nginx',
    #servicegroups       => 'nginx',
  }

}

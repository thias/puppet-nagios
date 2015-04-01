define nagios::check::moxi (
  $ensure = undef,
  $args   = undef,
) {

  # Generic overrides
  if $::nagios_check_moxi_check_period != undef {
    Nagios_service { check_period => $::nagios_check_moxi_check_period }
  }
  if $::nagios_check_moxi_notification_period != undef {
    Nagios_service { notification_period => $::nagios_check_moxi_notification_period }
  }

  # Service specific overrides
  if $::nagios_check_moxi_args != undef {
    $fullargs = $::nagios_check_moxi_args
  } else {
    $fullargs = $args
  }

  file { "${nagios::client::plugin_dir}/check_moxi":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('nagios/plugins/check_moxi'),
  }

  nagios::client::nrpe_file { 'check_moxi':
    ensure => $ensure,
    args   => $fullargs,
  }

  nagios::service { "check_moxi_${title}":
    ensure              => $ensure,
    check_command       => 'check_nrpe_moxi',
    service_description => 'moxi',
    #servicegroups       => 'moxi',
  }

}

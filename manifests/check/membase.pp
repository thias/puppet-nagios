define nagios::check::membase (
  $ensure                 = undef,
  $args                   = undef,
  $membase_data_file_name = '/tmp/membase_data_file_name',
  $membase_mbstats        = '/opt/membase/bin/mbstats',
  $membase_host           = '127.0.0.1',
  $membase_port           = '11211',
) {

  # Generic overrides
  if $::nagios_check_membase_check_period != undef {
    Nagios_service { check_period => $::nagios_check_membase_check_period }
  }
  if $::nagios_check_membase_notification_period != undef {
    Nagios_service { notification_period => $::nagios_check_membase_notification_period }
  }

  # Service specific overrides
  if $::nagios_check_membase_args != undef {
    $fullargs = $::nagios_check_membase_args
  } else {
    $fullargs = $args
  }

  file { "${nagios::client::plugin_dir}/check_membase":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('nagios/plugins/check_membase.erb'),
  }

  nagios::client::nrpe_file { 'check_membase':
    ensure => $ensure,
    args   => $fullargs,
  }

  nagios::service { "check_membase_${title}":
    ensure              => $ensure,
    check_command       => 'check_nrpe_membase',
    service_description => 'membase',
    #servicegroups       => 'membase',
  }

}


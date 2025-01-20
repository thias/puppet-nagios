define nagios::check::patroni::mode () {

  $mode = $title

  # Get the variables we need
  $check_title    = $::nagios::client::host_name
  $args           = $::nagios::check::patroni::args
  $modes_enabled  = $::nagios::check::patroni::modes_enabled
  $modes_disabled = $::nagios::check::patroni::modes_disabled
  $ensure         = $::nagios::check::patroni::ensure
  $plugin         = $::nagios::check::patroni::plugin

  # Get the args passed to the main class for our mode
  $args_mode = getvar("nagios::check::patroni::args_${mode}")

  if ( ( $modes_enabled == [] and $modes_disabled == [] ) or
    ( $modes_enabled != [] and $mode in $modes_enabled ) or
    ( $modes_disabled != [] and ! ( $mode in $modes_disabled ) ) )
  {
    nagios::client::nrpe_file { "check_patroni_${mode}":
      ensure => $ensure,
      plugin => $plugin,
      args   => "${args} ${title} ${args_mode}",
    }
    nagios::service { "check_patroni_${mode}_${check_title}":
      ensure              => $ensure,
      check_command       => "check_nrpe_patroni_${mode}",
      service_description => "patroni_${mode}",
      servicegroups       => 'patroni',
    }
  } else {
    nagios::client::nrpe_file { "check_patroni_${mode}":
      ensure => 'absent',
    }
    nagios::service { "check_patroni_${mode}_${check_title}":
      ensure        => 'absent',
      check_command => 'foo',
    }
  }

}


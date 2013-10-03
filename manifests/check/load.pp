class nagios::check::load (
  $args                = undef,
  $servicegroups       = undef,
  $check_period        = $::nagios::client::defaults::check_period,
  $max_check_attempts  = $::nagios::client::defaults::max_check_attempts,
  $notification_period = $::nagios::client::defaults::notification_period,
  $use                 = $::nagios::client::defaults::use,
  $ensure              = undef,
) inherits ::nagios::client::defaults {

  if $ensure != 'absent' {
    Package <| tag == 'nagios-plugins-load' |>
  }

  # We choose defaults based on the number of CPU cores.
  if $args == '' {
    if ( $::processorcount > 16 ) {
      $final_args = '-w 60,40,40 -c 90,70,70'
    } elsif ( $::processorcount > 8 ) and ( $::processorcount <= 16 ) {
      $final_args = '-w 25,20,20 -c 40,35,35'
    } elsif ( $::processorcount > 4 ) and ( $::processorcount <= 8 ) {
      $final_args = '-w 20,15,15 -c 35,30,30'
    } else {
      $final_args = '-w 15,10,10 -c 30,25,25'
    }
  } else {
    $final_args = $args
  }
  nagios::client::nrpe_file { 'check_load':
    args   => $final_args,
    ensure => $ensure,
  }

  nagios::service { "check_load_${title}":
    check_command       => 'check_nrpe_load',
    service_description => 'load',
    servicegroups       => $servicegroups,
    check_period        => $check_period,
    max_check_attempts  => $max_check_attempts,
    notification_period => $notification_period,
    use                 => $use,
    ensure              => $ensure,
  }

}


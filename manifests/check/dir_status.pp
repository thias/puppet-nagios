define nagios::check::dir_status (
  $args,
  $servicegroups       = $::nagios_check_dir_status_servicegroups,
  $check_period        = $::nagios_check_dir_status_check_period,
  $max_check_attempts  = $::nagios_check_dir_status_max_check_attempts,
  $notification_period = $::nagios_check_dir_status_notification_period,
  $use                 = $::nagios_check_dir_status_use,
  $ensure              = $::nagios_check_dir_status_ensure,
) {

  if $ensure != 'absent' {
    include '::nagios::plugin::dir_status'
  }

  nagios::client::nrpe_file { "check_dir_status_${title}":
    ensure => $ensure,
    args   => $args,
    plugin => 'check_dir_status',
  }

  nagios::service { "check_dir_status_${title}_${::nagios::client::host_name}":
    ensure              => $ensure,
    check_command       => "check_nrpe_dir_status_${title}",
    service_description => "dir_status_${title}",
    servicegroups       => $servicegroups,
    check_period        => $check_period,
    max_check_attempts  => $max_check_attempts,
    notification_period => $notification_period,
    use                 => $use,
  }

}


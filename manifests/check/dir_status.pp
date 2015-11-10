define nagios::check::dir_status (
  $ensure                   = $::nagios_check_dir_status_ensure,
  $args,
  $servicegroups            = $::nagios_check_dir_status_servicegroups,
  $check_period             = $::nagios_check_dir_status_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::first_notification_delay,
  $max_check_attempts       = $::nagios_check_dir_status_max_check_attempts,
  $notification_period      = $::nagios_check_dir_status_notification_period,
  $use                      = $::nagios::client::service_use,
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
    ensure                   => $ensure,
    check_command            => "check_nrpe_dir_status_${title}",
    service_description      => "dir_status_${title}",
    servicegroups            => $servicegroups,
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    max_check_attempts       => $max_check_attempts,
    notification_period      => $notification_period,
    use                      => $use,
  }

}

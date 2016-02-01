class nagios::check::mountpoints (
  $ensure                   = undef,
  $args                     = '-a -w',
  $check_title              = $::nagios::client::host_name,
  $servicegroups            = undef,
  $check_period             = $::nagios::client::service_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::first_notification_delay,
  $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  $notification_period      = $::nagios::client::service_notification_period,
  $use                      = $::nagios::client::service_use,
) inherits ::nagios::client {

  nagios::client::nrpe_plugin { 'check_mountpoints':
    ensure   => $ensure,
    sudo_cmd => '/usr/lib64/nagios/plugins/check_mountpoints',
  }

  nagios::client::nrpe_file { 'check_mountpoints':
    ensure => $ensure,
    args   => $args,
    sudo   => true,
  }

  nagios::service { "check_mountpoints_${check_title}":
    ensure                   => $ensure,
    check_command            => 'check_nrpe_mountpoints',
    service_description      => 'mountpoints',
    servicegroups            => $servicegroups,
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    notification_period      => $notification_period,
    max_check_attempts       => $max_check_attempts,
    use                      => $use,
  }

}

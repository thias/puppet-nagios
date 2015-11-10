class nagios::check::hpsa (
  $ensure                   = undef,
  $args                     = '',
  $package                  = 'hpssacli',
  $check_title              = $::nagios::client::host_name,
  $servicegroups            = undef,
  $check_period             = $::nagios::client::service_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::first_notification_delay,
  $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  $notification_period      = $::nagios::client::service_notification_period,
  $use                      = $::nagios::client::service_use,
) inherits ::nagios::client {

  nagios::client::nrpe_plugin { 'check_hpsa':
    ensure   => $ensure,
    perl     => true,
    # Main HP package and command, used by the check script
    package  => $package,
    sudo_cmd => '/usr/sbin/hpssacli',
  }

  nagios::client::nrpe_file { 'check_hpsa':
    ensure => $ensure,
    args   => $args,
  }

  nagios::service { "check_hpsa_${check_title}":
    ensure                   => $ensure,
    check_command            => 'check_nrpe_hpsa',
    service_description      => 'hpsa',
    servicegroups            => $servicegroups,
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    notification_period      => $notification_period,
    max_check_attempts       => $max_check_attempts,
    use                      => $use,
  }

}

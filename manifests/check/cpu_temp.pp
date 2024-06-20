# Check CPU temperature using lm_sensors
#
class nagios::check::cpu_temp (
  $ensure                   = undef,
  $args                     = '',
  $package                  = $::osfamily ? {'Debian' => 'lm-sensors',default => 'lm_sensors'},
  $check_title              = $::nagios::client::host_name,
  $servicegroups            = undef,
  $check_period             = $::nagios::client::service_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::service_first_notification_delay,
  $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  $notification_period      = $::nagios::client::service_notification_period,
  $use                      = $::nagios::client::service_use,
) inherits ::nagios::client {

  nagios::client::nrpe_plugin { 'check_cpu_temp':
    ensure  => $ensure,
    package => $package,
  }

  # System package(s) required by checks relying on 3rd party tools
  if $package != false and $ensure != 'absent' {
    ensure_packages($package)
  }

  nagios::client::nrpe_file { 'check_cpu_temp':
    ensure => $ensure,
    args   => $args,
  }

  nagios::service { "check_cpu_temp_${check_title}":
    ensure                   => $ensure,
    check_command            => 'check_nrpe_cpu_temp',
    service_description      => 'cpu_temp',
    servicegroups            => $servicegroups,
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    notification_period      => $notification_period,
    max_check_attempts       => $max_check_attempts,
    use                      => $use,
  }

}

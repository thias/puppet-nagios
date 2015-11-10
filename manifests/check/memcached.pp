class nagios::check::memcached (
  $ensure                   = undef,
  $args                     = '',
  $package                  = $::nagios::params::perl_memcached,
  $check_title              = $::nagios::client::host_name,
  $servicegroups            = undef,
  $check_period             = $::nagios::client::service_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::first_notification_delay,
  $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  $notification_period      = $::nagios::client::service_notification_period,
  $use                      = $::nagios::client::service_use,
) inherits ::nagios::client {

  nagios::client::nrpe_plugin { 'check_memcached':
    ensure  => $ensure,
    package => $package,
  }

  # Include defaults if no overrides in $args
  if $args !~ /-H/ { $arg_h = '-H 127.0.0.1 ' } else { $arg_h = '' }
  if $args !~ /-p/ { $arg_p = '-p 11211 ' }     else { $arg_p = '' }
  if $args !~ /-U/ { $arg_u = '-U 75,90 ' }     else { $arg_u = '' }
  $fullargs = strip("${arg_h}${arg_p}${arg_u}-f ${args}")

  nagios::client::nrpe_file { 'check_memcached':
    ensure => $ensure,
    args   => $fullargs,
  }

  nagios::service { "check_memcached_${check_title}":
    ensure                   => $ensure,
    check_command            => 'check_nrpe_memcached',
    service_description      => 'memcached',
    servicegroups            => $servicegroups,
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    notification_period      => $notification_period,
    max_check_attempts       => $max_check_attempts,
    use                      => $use,
  }

}

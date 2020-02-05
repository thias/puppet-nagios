class nagios::check::redis_sentinel (
  $ensure                   = undef,
  $package                  = 'rubygem-redis',
  $args                     = '',
  $master                   = undef,
  $check_title              = $::nagios::client::host_name,
  $servicegroups            = 'redis',
  $check_period             = $::nagios::client::service_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::service_first_notification_delay,
  $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  $notification_period      = $::nagios::client::service_notification_period,
  $use                      = $::nagios::client::service_use,
) inherits ::nagios::client {


  if $ensure == 'absent' {
    $ensure_mode = 'absent'
    $final_args = ''
  } else {
    $ensure_mode = 'present'
    if $args !~ /-m/ and $master != undef {
      $arg_m = "-m ${master}"
    } else {
      $arg_m = '-m localhost'
      notify{'redis_sentinel monitorization check requires master parameter':}
    }

    $final_args = "-H localhost ${arg_m} ${args}"
  }

  nagios::client::nrpe_file { 'check_sentinel_master_health':
    ensure  => $ensure_mode,
    args    => $final_args,
  }

  nagios::client::nrpe_plugin { 'check_sentinel_master_health':
    ensure  => $ensure_mode,
    package => $package,
  }

  nagios::service { "check_redis_sentinel_${check_title}":
    ensure                   => $ensure_mode,
    check_command            => 'check_sentinel_master_health',
    service_description      => 'redis_sentinel',
    servicegroups            => $servicegroups,
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    notification_period      => $notification_period,
    max_check_attempts       => $max_check_attempts,
    use                      => $use,
  }

}

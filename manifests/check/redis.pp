class nagios::check::redis (
  $ensure                       = undef,
  $package                      = 'perl-Redis',
  # common args for all modes 'as-is' for the check script
  $args                         = '',
  # common args for all modes as individual parameters
  $database                     = undef,
  $pass                         = undef,
  # modes selectively enabled and/or disabled
  $modes_enabled                = [],
  $modes_disabled               = [],
  $args_blocked_clients         = '',
  $args_connected_slaves        = '',
  $args_connected_clients       = '',
  $args_evicted_keys            = '',
  $args_hitrate                 = '',
  $args_response_time           = '',
  $args_rejected_connections    = '',
  $args_uptime_in_seconds       = '',
  # service
  $check_title              = $::nagios::client::host_name,
  $servicegroups            = 'redis',
  $check_period             = $::nagios::client::service_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::service_first_notification_delay,
  $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  $notification_period      = $::nagios::client::service_notification_period,
  $use                      = $::nagios::client::service_use,
) {

  nagios::client::nrpe_plugin { 'check_redis':
    ensure  => $ensure,
    package => $package,
  }

  # Set options from parameters unless already set inside args
  if $args !~ /-d/ and $database != undef {
    $arg_d = "-d ${database} "
  } else {
    $arg_d = ''
  }
  if $args !~ /-x/ and $pass != undef {
    $arg_p = "-x ${pass} "
  } else {
    $arg_p = ''
  }

  $globalargs = strip("-H localhost ${arg_d}${arg_p}${args}")

  $modes = [
    'blocked_clients',
    'connected_slaves',
    'connected_clients',
    'evicted_keys',
    'hitrate',
    'response_time',
    'rejected_connections',
    'uptime_in_seconds',
  ]
  nagios::check::redis::mode { $modes:
    ensure                   => $ensure,
    globalargs               => $globalargs,
    modes_enabled            => $modes_enabled,
    modes_disabled           => $modes_disabled,
    # service
    check_title              => $check_title,
    servicegroups            => $servicegroups,
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    max_check_attempts       => $max_check_attempts,
    notification_period      => $notification_period,
    use                      => $use,
  }

}

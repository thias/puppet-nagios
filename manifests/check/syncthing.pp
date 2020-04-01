class nagios::check::syncthing (
  $ensure                   = undef,
  $package                  = 'python-requests',
  # common args for all modes 'as-is' for the check script
  $args                     = '',
  # common args for all modes as individual parameters
  $api_key                  = undef,
  # modes selectively enabled and/or disabled
  $modes_enabled            = [],
  $modes_disabled           = [],
  # service
  $check_title              = $::nagios::client::host_name,
  $servicegroups            = 'syncthing',
  $check_period             = $::nagios::client::service_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::service_first_notification_delay,
  $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  $notification_period      = $::nagios::client::service_notification_period,
  $use                      = $::nagios::client::service_use,
) {

  nagios::client::nrpe_plugin { 'check_syncthing':
    ensure  => $ensure,
    package => $package,
  }

  # Set options from parameters unless already set inside args
  if $args !~ /-X/ and $api_key != undef {
    $arg_x = "-X ${api_key} "
  } else {
    $arg_x = ''
  }

  $globalargs = strip("-H localhost ${arg_x}${args}")

  $modes = [
    'alive',
    'devices',
    'folders_status',
    'last_scans',
  ]
  nagios::check::syncthing::mode { $modes:
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

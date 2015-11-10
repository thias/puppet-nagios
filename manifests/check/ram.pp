class nagios::check::ram (
  $ensure                   = undef,
  $args                     = '',
  $check_title              = $::nagios::client::host_name,
  $servicegroups            = undef,
  $check_period             = $::nagios::client::service_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::first_notification_delay,
  $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  $notification_period      = $::nagios::client::service_notification_period,
  $use                      = $::nagios::client::service_use,
) inherits ::nagios::client {

  nagios::client::nrpe_plugin { 'check_ram':
    ensure => $ensure,
  }

  # Include defaults if no overrides in $args
  if $args !~ /-w/ { $arg_w = '-w 10% ' } else { $arg_w = '' }
  if $args !~ /-c/ { $arg_c = '-c 5% ' }  else { $arg_c = '' }
  $fullargs = strip("${arg_w}${arg_c}${args}")

  nagios::client::nrpe_file { 'check_ram':
    ensure => $ensure,
    args   => $fullargs,
  }

  nagios::service { "check_ram_${check_title}":
    ensure                   => $ensure,
    check_command            => 'check_nrpe_ram',
    service_description      => 'ram',
    servicegroups            => $servicegroups,
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    notification_period      => $notification_period,
    max_check_attempts       => $max_check_attempts,
    use                      => $use,
  }

}

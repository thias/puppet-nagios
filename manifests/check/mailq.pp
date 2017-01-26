class nagios::check::mailq (
  $ensure                   = undef,
  $args                     = '',
  $check_title              = $::nagios::client::host_name,
  $servicegroups            = undef,
  $check_period             = $::nagios::client::service_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::service_first_notification_delay,
  $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  $notification_period      = $::nagios::client::service_notification_period,
  $use                      = $::nagios::client::service_use,
) inherits ::nagios::client {

  # Include defaults if no overrides in $args
  if $args !~ /-w/ { $arg_w = '-w 5 ' } else { $arg_w = '' }
  if $args !~ /-c/ { $arg_c = '-c 25 ' }  else { $arg_c = '' }
  $fullargs = strip("${arg_w}${arg_c}${args}")

  if $ensure != 'absent' {
    Package <| tag == 'nagios-plugins-mailq' |>
  }

  nagios::client::nrpe_file { 'check_mailq':
    ensure => $ensure,
    args   => $fullargs,
  }

  nagios::service { "check_mailq_${check_title}":
    ensure                   => $ensure,
    check_command            => 'check_nrpe_mailq',
    service_description      => 'mailq',
    servicegroups            => $servicegroups,
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    notification_period      => $notification_period,
    max_check_attempts       => $max_check_attempts,
    use                      => $use,

  }
}

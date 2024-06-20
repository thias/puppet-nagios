class nagios::check::ntp_time (
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
  $notes_url                = undef,
) inherits ::nagios::client {

  if $ensure != 'absent' {
    Package <| tag == 'nagios-plugins-ntp' |>
  }

  # Include defaults if no overrides in $args
  if $args !~ /-H/ { $arg_h = '-H 0.pool.ntp.org ' } else { $arg_h = '' }
  if $args !~ /-w/ { $arg_w = '-w 1 '              } else { $arg_w = '' }
  if $args !~ /-c/ { $arg_c = '-c 2 '              } else { $arg_c = '' }
  $fullargs = strip("${arg_h}${arg_w}${arg_c}${args}")

  nagios::client::nrpe_file { 'check_ntp_time':
    ensure => $ensure,
    args   => $fullargs,
  }

  nagios::service { "check_ntp_time_${check_title}":
    ensure                   => $ensure,
    check_command            => 'check_nrpe_ntp_time',
    service_description      => 'ntp_time',
    servicegroups            => $servicegroups,
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    notification_period      => $notification_period,
    max_check_attempts       => $max_check_attempts,
    use                      => $use,
    notes_url                => $notes_url,
  }

}

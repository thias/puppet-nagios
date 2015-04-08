class nagios::check::ntp_time (
  $ensure                   = undef,
  $args                     = '-w 1 -c 2',
  $ntp_server               = undef,
  $check_title              = $::nagios::client::host_name,
  $servicegroups            = undef,
  $check_period             = $::nagios::client::service_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::first_notification_delay,
  $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  $notification_period      = $::nagios::client::service_notification_period,
  $use                      = $::nagios::client::service_use,
) {

  # Required plugin
  if $ensure != 'absent' {
    Package <| tag == 'nagios-plugins-ntp' |>
  }
  # Include default host (-H) if no override in $args
  if $args !~ /-H/ { $arg_host = '-H 0.pool.ntp.org ' } else { $arg_host = '' }
  $fullargs = "${arg_host}${args}"

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
  }

}

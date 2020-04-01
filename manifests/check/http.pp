define nagios::check::http (
  $ensure                   = getvar('::nagios_check_http_ensure'),
  $args,
  $servicegroups            = undef,
  $check_period             = $::nagios::client::service_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::service_first_notification_delay,
  $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  $notification_period      = $::nagios::client::service_notification_period,
  $use                      = $::nagios::client::service_use,
) {

  if $ensure != 'absent' {
    Package <| tag == 'nagios-plugins-http' |>
  }

  nagios::client::nrpe_file { "check_http_${title}":
    ensure => $ensure,
    args   => $args,
    plugin => 'check_http',
  }

  nagios::service { "check_http_${title}_${::nagios::client::host_name}":
    ensure                   => $ensure,
    check_command            => "check_nrpe_http_${title}",
    service_description      => "http_${title}",
    servicegroups            => $servicegroups,
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    max_check_attempts       => $max_check_attempts,
    notification_period      => $notification_period,
    use                      => $use,
  }

}

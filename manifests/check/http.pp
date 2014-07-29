define nagios::check::http (
  $args,
  $servicegroups       = $::nagios_check_http_servicegroups,
  $check_period        = $::nagios_check_http_check_period,
  $max_check_attempts  = $::nagios_check_http_max_check_attempts,
  $notification_period = $::nagios_check_http_notification_period,
  $use                 = $::nagios_check_http_use,
  $ensure              = $::nagios_check_http_ensure,
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
    ensure              => $ensure,
    check_command       => "check_nrpe_http_${title}",
    service_description => "http_${title}",
    servicegroups       => $servicegroups,
    check_period        => $check_period,
    max_check_attempts  => $max_check_attempts,
    notification_period => $notification_period,
    use                 => $use,
  }

}


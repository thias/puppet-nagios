define nagios::check::http_perf (
  $args,
  $servicegroups       = $::nagios_check_http_perf_servicegroups,
  $check_period        = $::nagios_check_http_perf_check_period,
  $max_check_attempts  = $::nagios_check_http_perf_max_check_attempts,
  $notification_period = $::nagios_check_http_perf_notification_period,
  $use                 = $::nagios_check_http_perf_use,
  $ensure              = $::nagios_check_http_perf_ensure,
) {

  include '::nagios::plugin::http_perf'

  nagios::client::nrpe_file { "check_http_perf_${title}":
    ensure => $ensure,
    args   => $args,
    plugin => 'check_http_perf',
  }

  nagios::service { "check_http_perf_${title}_${::nagios::client::host_name}":
    ensure              => $ensure,
    check_command       => "check_nrpe_http_perf_${title}",
    service_description => "http_perf_${title}",
    servicegroups       => $servicegroups,
    check_period        => $check_period,
    max_check_attempts  => $max_check_attempts,
    notification_period => $notification_period,
    use                 => $use,
  }

}


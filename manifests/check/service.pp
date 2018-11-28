define nagios::check::service (
  $ensure                   = undef,
  $check_title              = $::nagios::client::host_name,
  $servicegroups            = undef,
  $check_period             = $::nagios::client::service_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::service_first_notification_delay,
  $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  $notification_period      = $::nagios::client::service_notification_period,
  $use                      = $::nagios::client::service_use,
) {

  ensure_resource('nagios::client::nrpe_plugin', 'check_service', {'ensure' => $ensure})

  $nrpe_command   = $::nagios::params::nrpe_command
  $nrpe_options   = $::nagios::params::nrpe_options
  $nrpe           = "${nrpe_command} ${nrpe_options}"

  @@nagios_command { "check_nrpe_service_${title}_${::fqdn}":
    command_line => "${nrpe} -c check_service_${title}",
    tag          => 'service',
  }

  nagios::client::nrpe_file { "check_service_${title}":
    ensure => $ensure,
    args   => "-s ${title}",
    plugin => 'check_service',
  }

  nagios::service { "check_service_${title}_${::nagios::client::host_name}":
    ensure                   => $ensure,
    check_command            => "check_nrpe_service_${title}_${::fqdn}",
    service_description      => "service_${title}",
    servicegroups            => $servicegroups,
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    notification_period      => $notification_period,
    max_check_attempts       => $max_check_attempts,
    use                      => $use,
  }
}

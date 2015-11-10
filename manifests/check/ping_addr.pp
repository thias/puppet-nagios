define nagios::check::ping_addr (
  $ensure                   = $::nagios_check_ping_addr_ensure,
  $address                  = $::nagios::client::host_address,
  $warning                  = '2000.0,50%',
  $critical                 = '5000.0,100%',
  $servicegroups            = $::nagios_check_ping_addr_servicegroups,
  $check_period             = $::nagios_check_ping_addr_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::first_notification_delay,
  $max_check_attempts       = $::nagios_check_ping_addr_max_check_attempts,
  $notification_period      = $::nagios_check_ping_addr_notification_period,
  $use                      = $::nagios::client::service_use,
) {

  nagios::service { "check_ping_addr_${title}_${::nagios::client::host_name}":
    ensure                   => $ensure,
    check_command            => "check_ping_addr!${address}!${warning}!${critical}",
    service_description      => "ping_addr_${title}",
    servicegroups            => $servicegroups,
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    max_check_attempts       => $max_check_attempts,
    notification_period      => $notification_period,
    use                      => $use,
  }

}

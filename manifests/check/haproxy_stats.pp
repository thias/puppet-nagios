class nagios::check::haproxy_stats (
  $ensure                   = undef,
  $args                     = '-s /var/lib/haproxy/stats -P statistics -m',
  $package                  = [ 'perl' ],
  $vendor_package           = undef,
  $check_title              = $::nagios::client::host_name,
  $servicegroups            = undef,
  $check_period             = $::nagios::client::service_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::service_first_notification_delay,
  $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  $notification_period      = $::nagios::client::service_notification_period,
  $use                      = $::nagios::client::service_use,
) {
  nagios::client::nrpe_plugin { 'check_haproxy_stats':
    ensure   => $ensure,
    sudo_cmd => '/usr/lib64/nagios/plugins/check_haproxy_stats',
  }

  nagios::client::nrpe_file { 'check_haproxy_stats':
    ensure => $ensure,
    sudo   => true,
    args   => $args,
  }

  nagios::service { "check_haproxy_stats_${check_title}":
    ensure                   => $ensure,
    check_command            => 'check_nrpe_haproxy_stats',
    service_description      => 'haproxy_stats',
    servicegroups            => $servicegroups,
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    notification_period      => $notification_period,
    max_check_attempts       => $max_check_attempts,
    use                      => $use,
  }

}

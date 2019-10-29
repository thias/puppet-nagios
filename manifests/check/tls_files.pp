class nagios::check::tls_files (
  $ensure                   = undef,
  $args                     = '',
  $package                  = [ $::nagios::params::python_openssl ],
  $vendor_package           = undef,
  $check_title              = $::nagios::client::host_name,
  $servicegroups            = undef,
  $check_interval           = 60,
  $check_period             = $::nagios::client::service_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::service_first_notification_delay,
  $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  $notification_period      = $::nagios::client::service_notification_period,
  $use                      = $::nagios::client::service_use,
) {

  nagios::client::nrpe_plugin { 'check_tls_files':
    ensure  => $ensure,
    package => $package,
  }

  nagios::client::nrpe_file { 'check_tls_files':
    ensure => $ensure,
    args   => $args,
  }

  nagios::service { "check_tls_files_${check_title}":
    ensure                   => $ensure,
    check_command            => 'check_nrpe_tls_files',
    service_description      => 'tls_files',
    check_interval           => $check_interval,
    servicegroups            => $servicegroups,
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    notification_period      => $notification_period,
    max_check_attempts       => $max_check_attempts,
    use                      => $use,
  }
}

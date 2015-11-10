class nagios::check::mptsas (
  $ensure                   = undef,
  $args                     = '',
  $package                  = 'lsiutil',
  $lsiutilbin               = '/usr/sbin/lsiutil',
  $check_title              = $::nagios::client::host_name,
  $servicegroups            = undef,
  $check_period             = $::nagios::client::service_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::first_notification_delay,
  $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  $notification_period      = $::nagios::client::service_notification_period,
  $use                      = $::nagios::client::service_use,
) {

  nagios::client::nrpe_plugin { 'check_mptsas':
    ensure   => $ensure,
    perl     => true,
    # We customize the lsiutil path, plugin path
    erb      => true,
    # Main LSI package and command, used by the check script
    package  => $package,
    # The check executes lsiutil using sudo
    sudo_cmd => $lsiutilbin,
  }

  nagios::client::nrpe_file { 'check_mptsas':
    ensure => $ensure,
    args   => $fullargs,
  }

  nagios::service { "check_mptsas_${check_title}":
    ensure                   => $ensure,
    check_command            => 'check_nrpe_mptsas',
    service_description      => 'mptsas',
    servicegroups            => $servicegroups,
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    notification_period      => $notification_period,
    max_check_attempts       => $max_check_attempts,
    use                      => $use,
  }

}

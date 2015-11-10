class nagios::check::megaraid_sas (
  $ensure                   = undef,
  $args                     = '',
  $package                  = 'megacli',
  $megaclibin               = $::nagios::params::megaclibin,
  $check_title              = $::nagios::client::host_name,
  $servicegroups            = undef,
  $check_period             = $::nagios::client::service_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::first_notification_delay,
  $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  $notification_period      = $::nagios::client::service_notification_period,
  $use                      = $::nagios::client::service_use,
) {

  nagios::client::nrpe_plugin { 'check_megaraid_sas':
    ensure   => $ensure,
    perl     => true,
    # We customize the MegaCli path, plugin path
    erb      => true,
    # Main LSI package and command, used by the check script
    package  => $package,
    # The check executes MegaCli using sudo
    sudo_cmd => $megaclibin,
  }

  nagios::client::nrpe_file { 'check_megaraid_sas':
    ensure => $ensure,
    args   => $args,
  }

  nagios::service { "check_megaraid_sas_${check_title}":
    ensure                   => $ensure,
    check_command            => 'check_nrpe_megaraid_sas',
    service_description      => 'megaraid_sas',
    servicegroups            => $servicegroups,
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    notification_period      => $notification_period,
    max_check_attempts       => $max_check_attempts,
    use                      => $use,
  }

}

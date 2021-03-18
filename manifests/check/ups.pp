class nagios::check::ups (
  $ensure                   = undef,
  $args                     = '-H 127.0.0.1 -u nutdev1',
  $package                  = [ 'nagios-plugins-ups' ],
  $sudo_user                = 'nut',
  $check_title              = $::nagios::client::host_name,
  $servicegroups            = undef,
  $check_period             = $::nagios::client::service_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::service_first_notification_delay,
  $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  $notification_period      = $::nagios::client::service_notification_period,
  $use                      = $::nagios::client::service_use,
) {

  nagios::client::nrpe_plugin { 'check_ups':
    ensure          => $ensure,
    package         => $package,
    sudo_cmd        => '/usr/lib64/nagios/plugins/check_ups',
    sudo_user       => $sudo_user,
    plugin_template => false,
  }

  nagios::client::nrpe_file { 'check_ups':
    ensure    => $ensure,
    sudo      => true,
    args      => $args,
    sudo_user => $sudo_user,
  }

  nagios::service { "check_ups${check_title}":
    ensure                   => $ensure,
    check_command            => 'check_nrpe_ups',
    service_description      => 'ups',
    servicegroups            => $servicegroups,
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    notification_period      => $notification_period,
    max_check_attempts       => $max_check_attempts,
    use                      => $use,
  }

}

class nagios::check::ipa (
  $ensure                   = undef,
  $args                     = '',
  $ipactl_bin               = '/sbin/ipactl',
  $check_title              = $::nagios::client::host_name,
  $servicegroups            = undef,
  $check_period             = $::nagios::client::service_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::service_first_notification_delay,
  $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  $notification_period      = $::nagios::client::service_notification_period,
  $use                      = $::nagios::client::service_use,
) {

  nagios::client::nrpe_plugin { 'check_ipa':
    ensure   => $ensure,
    # The check executes ipactl using sudo
    sudo_cmd => "${ipactl_bin} status",
  }

  nagios::client::nrpe_file { 'check_ipa':
    ensure => $ensure,
    args   => $args,
  }

  nagios::service { "check_ipa_${check_title}":
    ensure                   => $ensure,
    check_command            => 'check_nrpe_ipa',
    service_description      => 'ipa',
    servicegroups            => $servicegroups,
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    notification_period      => $notification_period,
    max_check_attempts       => $max_check_attempts,
    use                      => $use,
  }

}

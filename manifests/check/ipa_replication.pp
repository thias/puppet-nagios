class nagios::check::ipa_replication (
  $ensure                   = undef,
  $args                     = '',
  $bind_dn                  = undef,
  $bind_pass                = undef,
  $ldap_uri                 = 'ldaps://localhost',
  $package                  = [ 'python-ldap', 'pynag'],
  $check_title              = $::nagios::client::host_name,
  $servicegroups            = undef,
  $check_period             = $::nagios::client::service_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::service_first_notification_delay,
  $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  $notification_period      = $::nagios::client::service_notification_period,
  $use                      = $::nagios::client::service_use,
) {

  if $args !~ /-u/ and $ldap_uri != undef {
    $arg_u = "-u ${ldap_uri} "
  } else {
    $arg_u = ''
  }
  if $args !~ /-D/ and $bind_dn != undef {
    $arg_d = "-D ${bind_dn} "
  } else {
    $arg_d = ''
  }
  if $args !~ /-w/ and $bind_pass != undef {
    $arg_p = "-w ${bind_pass} "
  } else {
    $arg_p = ''
  }

  $globalargs = strip(" ${arg_u}${arg_d}${arg_p}${args}")


  nagios::client::nrpe_plugin { 'check_ipa_replication':
    ensure  => $ensure,
    package => $package,
  }

  nagios::client::nrpe_file { 'check_ipa_replication':
    ensure => $ensure,
    args   => $globalargs,
  }

  nagios::service { "check_ipa_replication_${check_title}":
    ensure                   => $ensure,
    check_command            => 'check_nrpe_ipa_replication',
    service_description      => 'ipa_replication',
    servicegroups            => $servicegroups,
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    notification_period      => $notification_period,
    max_check_attempts       => $max_check_attempts,
    use                      => $use,
  }

}

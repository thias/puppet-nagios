class nagios::check::krb5 (
  $ensure                   = undef,
  $args                     = '',
  $keytab                   = undef,
  $principal                = undef,
  $port                     = undef,
  $realm                    = undef,
  $package                  = [ 'perl-Krb5', 'perl-File-MkTemp'],
  $check_title              = $::nagios::client::host_name,
  $servicegroups            = undef,
  $check_period             = $::nagios::client::service_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::service_first_notification_delay,
  $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  $notification_period      = $::nagios::client::service_notification_period,
  $use                      = $::nagios::client::service_use,
) {

  if $args !~ /-r/ and $realm != undef {
    $arg_r = "-r ${realm} "
  } else {
    $arg_r = ''
  }
  if $args !~ /-p/ and $principal != undef {
    $arg_pr = "-p ${principal} "
  } else {
    $arg_pr = ''
  }
  if $args !~ /-k/ and $keytab != undef {
    $arg_k = "-k ${keytab} "
  } else {
    $arg_k = ''
  }
  if $args !~ /-P/ and $port != undef {
    $arg_p = "-P ${port} "
  } else {
    $arg_p = ''
  }

  $globalargs = strip(" -H localhost ${arg_r}${arg_pr}${arg_p}${arg_k}${args}")


  nagios::client::nrpe_plugin { 'check_krb5':
    ensure  => $ensure,
    perl    => true,
    package => $package,
  }

  nagios::client::nrpe_file { 'check_krb5':
    ensure => $ensure,
    args   => $globalargs,
  }

  nagios::service { "check_krb5_${check_title}":
    ensure                   => $ensure,
    check_command            => 'check_nrpe_krb5',
    service_description      => 'krb5',
    servicegroups            => $servicegroups,
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    notification_period      => $notification_period,
    max_check_attempts       => $max_check_attempts,
    use                      => $use,
  }

}

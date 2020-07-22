class nagios::check::couchbase_bucket (
  $ensure                   = undef,
  $args                     = '',
  $couchbase_username       = undef,
  $couchbase_password       = undef,
  $package                  = [ 'jq' ],
  $check_title              = $::nagios::client::host_name,
  $servicegroups            = undef,
  $check_period             = $::nagios::client::service_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::service_first_notification_delay,
  $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  $notification_period      = $::nagios::client::service_notification_period,
  $use                      = $::nagios::client::service_use,
) inherits ::nagios::client {

  # Set options from parameters unless already set inside args
  if $args !~ /-u/ and $couchbase_username != undef {
    $arg_u = "-u ${couchbase_username} "
  } else {
    $arg_u = ''
  }
  if $args !~ /-p/ and $couchbase_password != undef {
    $arg_p = "-p ${couchbase_password} "
  } else {
    $arg_p = ''
  }
  $globalargs = strip("${arg_u}${arg_p}${args}")

  nagios::client::nrpe_plugin { 'check_couchbase_bucket':
    ensure  => $ensure,
    package => $package,
  }

  nagios::client::nrpe_file { 'check_couchbase_bucket':
    ensure => $ensure,
    args   => $globalargs,
  }

  nagios::service { "check_couchbase_bucket_${check_title}":
    ensure                   => $ensure,
    check_command            => 'check_nrpe_couchbase_bucket',
    service_description      => 'couchbase bucket',
    servicegroups            => $servicegroups,
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    notification_period      => $notification_period,
    max_check_attempts       => $max_check_attempts,
    use                      => $use,
  }

}

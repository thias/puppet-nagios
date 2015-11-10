class nagios::check::couchbase (
  $ensure                   = undef,
  $args                     = '',
  $couchbase_data_file_name = '/tmp/couchbase_data_file_name',
  $couchbase_cbstats        = '/opt/couchbase/bin/cbstats',
  $couchbase_host           = '127.0.0.1',
  $couchbase_port           = '11211',
  $check_title              = $::nagios::client::host_name,
  $servicegroups            = undef,
  $check_period             = $::nagios::client::service_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::first_notification_delay,
  $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  $notification_period      = $::nagios::client::service_notification_period,
  $use                      = $::nagios::client::service_use,
) inherits ::nagios::client {

  nagios::client::nrpe_plugin { 'check_couchbase':
    ensure => $ensure,
    # We use all of the $couchbase_* parameters inside the template
    erb    => true,
  }

  nagios::client::nrpe_file { 'check_couchbase':
    ensure => $ensure,
    args   => $args,
  }

  nagios::service { "check_couchbase_${check_title}":
    ensure                   => $ensure,
    check_command            => 'check_nrpe_couchbase',
    service_description      => 'couchbase',
    servicegroups            => $servicegroups,
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    notification_period      => $notification_period,
    max_check_attempts       => $max_check_attempts,
    use                      => $use,
  }

}

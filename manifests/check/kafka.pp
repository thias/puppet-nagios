class nagios::check::kafka (
  $ensure                   = undef,
  $args                     = '',
  $topic                    = undef,
  $brokers                  = undef,
  $package                  = [ 'python-harisekhon-utils', 'python-kafka' ],
  $check_title              = $::nagios::client::host_name,
  $check_period             = $::nagios::client::service_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::service_first_notification_delay,
  $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  $notification_period      = $::nagios::client::service_notification_period,
  $use                      = $::nagios::client::service_use,
) {

  # Set options from parameters unless already set inside args
  if $args !~ /-T/ and $args !~ /--topic/ and $topic != undef {
    $arg_t = "-T ${topic} "
  } else {
    $arg_t = ''
  }
  if $args !~ /-B/ and $args !~ /--brokers/ and $brokers != undef {
    $brokers_final = join($brokers, ',')
    $arg_b = "-B ${brokers_final} "
  } else {
    $arg_b = ''
  }
  $globalargs = strip("${arg_t}${arg_b}${args}")

  nagios::client::nrpe_plugin { 'check_kafka':
    ensure  => $ensure,
    package => $package,
  }

  nagios::client::nrpe_file { 'check_kafka':
    ensure => $ensure,
    args   => $globalargs,
  }

  nagios::service { "check_kafka_${check_title}":
    ensure                   => $ensure,
    check_command            => 'check_nrpe_kafka',
    service_description      => 'kafka',
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    notification_period      => $notification_period,
    max_check_attempts       => $max_check_attempts,
    use                      => $use,
  }

}

class nagios::check::kafka_isr (
  $ensure                   = undef,
  $args                     = '',
  $zookeeper_ipaddr         = [],
  $zookeeper_port           = 2181,
  $zookeeper_chroot         = undef,
  $package                  = [],
  $check_title              = $::nagios::client::host_name,
  $check_period             = $::nagios::client::service_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::service_first_notification_delay,
  $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  $notification_period      = $::nagios::client::service_notification_period,
  $use                      = $::nagios::client::service_use,
) {

  $zookeeper_hosts = join(map($zookeeper_ipaddr) |$ipaddr| { "${ipaddr}:${zookeeper_port}" }, ',')
  $zookeeper_final = "${zookeeper_hosts}/${zookeeper_chroot}"

  # Set options from parameters unless already set inside args
  if $args !~ /-z/ and $zookeeper_final != undef {
    $arg_z = "-z ${zookeeper_final} "
  } else {
    $arg_z = ''
  }
  $globalargs = strip("${arg_z}${args}")

  nagios::client::nrpe_plugin { 'check_kafka_isr':
    ensure  => $ensure,
    package => $package,
  }

  nagios::client::nrpe_file { 'check_kafka_isr':
    ensure => $ensure,
    args   => $globalargs,
  }

  nagios::service { "check_kafka_isr_${check_title}":
    ensure                   => $ensure,
    check_command            => 'check_nrpe_kafka_isr',
    service_description      => 'kafka_isr',
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    notification_period      => $notification_period,
    max_check_attempts       => $max_check_attempts,
    use                      => $use,
  }

}

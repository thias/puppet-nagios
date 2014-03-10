class nagios::check::cpu (
  $ensure                   = undef,
  $args                     = '-w 10 -c 5',
  $check_title              = $::nagios::client::host_name,
  $servicegroups            = undef,
  $check_period             = $::nagios::client::service_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::first_notification_delay,
  $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  $notification_period      = $::nagios::client::service_notification_period,
  $use                      = $::nagios::client::service_use,
) {

  # Service specific script
  file { "${nagios::client::plugin_dir}/check_cpu":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('nagios/plugins/check_cpu'),
  }

  nagios::client::nrpe_file { 'check_cpu':
    ensure => $ensure,
    args   => $args,
  }

  nagios::service { "check_cpu_${check_title}":
    ensure                   => $ensure,
    check_command            => 'check_nrpe_cpu',
    service_description      => 'cpu',
    servicegroups            => $servicegroups,
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    notification_period      => $notification_period,
    max_check_attempts       => $max_check_attempts,
    use                      => $use,
  }

}


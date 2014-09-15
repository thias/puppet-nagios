class nagios::check::memcached (
  $ensure                   = undef,
  $args                     = '-U 75,90 -f',
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
  if $ensure != 'absent' {
    package { $::nagios::params::perl_memcached: ensure => installed }
  }
  file { "${nagios::client::plugin_dir}/check_memcached":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('nagios/plugins/check_memcached'),
  }

  # Include default host (-H) and port (-p) if no override in $args
  if $args !~ /-H/ { $arg_host = '-H 127.0.0.1 ' }
  if $args !~ /-p/ { $arg_port = '-p 11211 ' }
  $fullargs = "${arg_host}${arg_port}${args}"

  nagios::client::nrpe_file { 'check_memcached':
    ensure  => $ensure,
    args    => $fullargs,
  }

  nagios::service { "check_memcached_${check_title}":
    ensure                   => $ensure,
    check_command            => 'check_nrpe_memcached',
    service_description      => 'memcached',
    servicegroups            => $servicegroups,
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    notification_period      => $notification_period,
    max_check_attempts       => $max_check_attempts,
    use                      => $use,
  }

}


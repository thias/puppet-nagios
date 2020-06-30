class nagios::check::consul (
  $ensure                   = undef,
  $args                     = '',
  $address                  = undef,
  $node                     = $::hostname,
  $datacenter               = 'default',
  $token                    = undef,
  $package                  = [ 'python-docopt', 'python-requests' ],
  $check_title              = $::nagios::client::host_name,
  $check_period             = $::nagios::client::service_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::service_first_notification_delay,
  $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  $notification_period      = $::nagios::client::service_notification_period,
  $use                      = $::nagios::client::service_use,
) {

  # Set options from parameters unless already set inside args
  if $args !~ /--addr/ and $address != undef {
    $arg_a = "--addr ${address} "
  } else {
    $arg_a = ''
  }
  if $args !~ /--token/ and $token != undef {
    $arg_t = "--token ${token} "
  } else {
    $arg_t = ''
  }
  $globalargs = strip("node ${node} ${datacenter} ${arg_a}${arg_t}${args}")

  nagios::client::nrpe_plugin { 'check_consul':
    ensure  => $ensure,
    package => $package,
  }

  nagios::client::nrpe_file { 'check_consul':
    ensure => $ensure,
    args   => $globalargs,
  }

  nagios::service { "check_consul_${check_title}":
    ensure                   => $ensure,
    check_command            => 'check_nrpe_consul',
    service_description      => 'consul',
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    notification_period      => $notification_period,
    max_check_attempts       => $max_check_attempts,
    use                      => $use,
  }

}

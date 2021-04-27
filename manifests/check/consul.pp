class nagios::check::consul (
  $ensure                   = undef,
  $args                     = '',
  $node                     = $::fqdn,
  $datacenter               = '',
  $token                    = undef,
  $package                  = undef,
  $check_title              = $::nagios::client::host_name,
  $check_period             = $::nagios::client::service_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::service_first_notification_delay,
  $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  $notification_period      = $::nagios::client::service_notification_period,
  $use                      = $::nagios::client::service_use,
) {

  if $package {
    $package_final = $package
  } else {
    if versioncmp($::operatingsystemmajrelease,'8') >= 0 {
      $package_final = [ 'python3-docopt', 'python3-requests' ]
    } else {
      $package_final = [ 'python-docopt', 'python-requests' ]
    }
  }

  # Set options from parameters unless already set inside args
  if $args !~ /--token/ and $token != undef {
    $arg_t = "--token ${token} "
  } else {
    $arg_t = ''
  }
  $globalargs = strip("node ${node} '${datacenter}' ${arg_t}${args}")

  nagios::client::nrpe_plugin { 'check_consul':
    erb     => true,
    ensure  => $ensure,
    package => $package_final,
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


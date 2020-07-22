class nagios::check::zookeeper (
  $args                               = undef,
  $check_period                       = undef,
  $first_notification_delay           = undef,
  $notification_period                = undef,
  $keys_enabled                       = [],
  $keys_disabled                      = [],
  $pkg                                = true,
  $ensure                             = undef,
  $leader                             = false,
  $plugin                             = 'check_zookeeper',
  # Keys
  $args_zk_avg_latency                = '-w 1 -c 10',
  $args_zk_max_latency                = '-w 10 -c 20',
  $args_zk_outstanding_requests       = '-w 10 -c 20',
  $args_zk_open_file_descriptor_count = '-w 3481 -c 3890',
  # Leader only keys
  $args_zk_pending_syncs              = '-w 10 -c 20',
  $args_zk_synced_followers           = '-w 3 -c 3',
) {

  # Generic overrides
  if $check_period {
    Nagios_service { check_period => $::nagios_check_zookeeper_period }
  }
  if $first_notification_delay {
    Nagios_service { first_notification_delay => $::nagios_check_zookeeper_first_notification_delay }
  }
  if $notification_period {
    Nagios_service { notification_period => $::nagios_check_zookeeper_notification_period }
  }

  # Optional package containing the script
  if $pkg {
    $pkgname = 'nagios-plugins-zookeeper'
    $pkgensure = $ensure ? {
      'absent' => 'absent',
      default  => 'installed',
    }
    package { $pkgname: ensure => $pkgensure }
  }

  # Modes-specific definition
  nagios::check::zookeeper::key { [
    'zk_avg_latency',
    'zk_max_latency',
    'zk_outstanding_requests',
    'zk_open_file_descriptor_count',
    'zk_pending_syncs',
    'zk_synced_followers',
  ]:
  }

}


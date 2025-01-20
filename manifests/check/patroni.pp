class nagios::check::patroni (
  $args                               = undef,
  $check_period                       = undef,
  $first_notification_delay           = undef,
  $notification_period                = undef,
  $modes_enabled                      = [],
  $modes_disabled                     = [],
  $ensure                             = undef,
  $plugin                             = 'check_patroni',
  $args_cluster_has_replica           = '-w 0 -c 0',
  $args_cluster_node_count            = '-w 1 -c 0',
  $args_node_is_leader                = '',
  $args_node_is_replica               = '',
  $args_node_has_version              = '--version 4.0.4',
  $args_node_replica_lag              = "-w 50 -c 100 --name ${::fqdn}",
) {

  include 'nagios::plugin::patroni'

  # Generic overrides
  if $check_period {
    Nagios_service { check_period => $::nagios_check_patroni_period }
  }
  if $first_notification_delay {
    Nagios_service { first_notification_delay => $::nagios_check_patroni_first_notification_delay }
  }
  if $notification_period {
    Nagios_service { notification_period => $::nagios_check_patroni_notification_period }
  }

  # Modes-specific definition
  nagios::check::patroni::mode { [
    #'node_has_version',
    #'node_is_leader',
    #'node_is_primary',
    'cluster_has_leader',
    'cluster_has_replica',
    'cluster_has_scheduled_action',
    'cluster_is_in_maintenance',
    'cluster_node_count',
    'node_is_alive',
    'node_is_pending_restart',
    'node_is_replica',
    'node_replica_lag',
  ]:
  }

}


#
# Class to enable ClickHouse monitoring
#
class nagios::check::clickhouse (
  Variant[String,Undef] $ensure                   = undef,
  Variant[String,Undef] $args                     = undef,
  Variant[String,Undef] $check_period             = undef,
  Variant[String,Undef] $first_notification_delay = undef,
  Variant[String,Undef] $notification_period      = undef,
  Array[String]         $modes_enabled            = [],
  Array[String]         $modes_disabled           = [],
  String                $plugin                   = 'check_clickhouse',
  # Modes
  String $args_replication_future_parts           = '',
  String $args_replication_inserts_in_queue       = '',
  String $args_replication_is_readonly            = '',
  String $args_replication_is_session_expired     = '',
  String $args_replication_log_delay              = '',
  String $args_replication_parts_to_check         = '',
  String $args_replication_queue_size             = '',
  String $args_replication_total_replicas         = '',
  String $args_replication_active_replicas        = '',
) {

  # Generic overrides
  if $check_period {
    Nagios_service { check_period => $::nagios_check_clickhouse_period }
  }
  if $first_notification_delay {
    Nagios_service { first_notification_delay => $::nagios_check_clickhouse_first_notification_delay }
  }
  if $notification_period {
    Nagios_service { notification_period => $::nagios_check_clickhouse_notification_period }
  }

  nagios::client::nrpe_plugin { 'check_clickhouse':
    ensure  => $ensure,
  }

  # Modes-specific definition
  nagios::check::clickhouse::mode { [
    'replication_future_parts',
    'replication_inserts_in_queue',
    'replication_is_readonly',
    'replication_is_session_expired',
    'replication_log_delay',
    'replication_parts_to_check',
    'replication_queue_size',
    'replication_total_replicas',
    'replication_active_replicas',
  ]:
  }

}


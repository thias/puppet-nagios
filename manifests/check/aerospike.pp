#
# Class to enable Aerospike monitoring
#
class nagios::check::aerospike (
  Optional[String] $ensure                   = undef,
  Optional[String] $args                     = undef,
  Optional[String] $check_period             = undef,
  Optional[String] $first_notification_delay = undef,
  Optional[String] $notification_period      = undef,
  Array[String]    $modes_enabled            = [],
  Array[String]    $modes_disabled           = [],
  String           $plugin                   = 'check_aerospike',
  # Modes
  String           $args_cluster_size        = '-w 1: -c 1:',
  String           $args_objects             = '-w 50: -c 10:',
  String           $args_query_long_running  = '-w 0 -c 2',
  String           $args_uptime              = '-w 15: -c 15:',
) {

  # Generic overrides
  if $check_period {
    Nagios_service { check_period => $::nagios_check_aerospike_period }
  }
  if $first_notification_delay {
    Nagios_service { first_notification_delay => $::nagios_check_aerospike_first_notification_delay }
  }
  if $notification_period {
    Nagios_service { notification_period => $::nagios_check_aerospike_notification_period }
  }

  nagios::client::nrpe_plugin { 'check_aerospike':
    ensure => $ensure,
    erb    => true,
  }

  # Modes-specific definition
  nagios::check::aerospike::mode { [
    'cluster_size',
    'objects',
    'uptime',
    'query_long_running',
  ]:
  }

}


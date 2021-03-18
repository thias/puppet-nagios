#
# ElasticSearch nagios check
#
class nagios::check::elasticsearch (
  Enum['present','absent'] $ensure                   = 'present',
  String                   $args                     = '',
  Optional[String]         $host                     = undef,
  Optional[String]         $port                     = undef,
  Optional[String]         $node                     = undef,
  Array[String]            $modes_enabled            = [],
  Array[String]            $modes_disabled           = [],
  # Modes
  String                   $args_cluster_status      = '',
  String                   $args_jvm_usage           = '',
  String                   $args_nodes               = '',
  String                   $args_split_brain         = '',
  String                   $args_unassigned_shards   = '',
  Optional[String]         $check_title              = $::nagios::client::host_name,
  Optional[String]         $check_period             = $::nagios::client::service_check_period,
  Optional[String]         $contact_groups           = $::nagios::client::service_contact_groups,
  Optional[String]         $first_notification_delay = $::nagios::client::service_first_notification_delay,
  Optional[String]         $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  Optional[String]         $notification_period      = $::nagios::client::service_notification_period,
  Optional[String]         $use                      = $::nagios::client::service_use,
  Optional[String]         $servicegroups            = $::nagios::client::service_servicegroups,
) {

  # Set options from parameters unless already set inside args
  if $args !~ /-H/ and $host != undef {
    $arg_h = "-H ${host} "
  } else {
    $arg_h = ''
  }
  if $args !~ /-P/ and $port != undef {
    $arg_p = "-P ${port} "
  } else {
    $arg_p = ''
  }
  if $args !~ /-N/ and $node != undef {
    $arg_n = "-N ${node} "
  } else {
    $arg_n = ''
  }
  $globalargs = strip("${arg_h}${arg_p}${arg_n}${args}")

  $modes = [
    'cluster_status',
    'nodes',
    'unassigned_shards',
    'jvm_usage',
    'split_brain',
  ]

  $check_modes = prefix($modes,'check_es_')
  nagios::client::nrpe_plugin { $check_modes:
    ensure  => $ensure,
  }

  realize Nagios::Client::Nrpe_plugin['nagioscheck.py']

  nagios::check::elasticsearch::mode { $modes:
    ensure                   => $ensure,
    globalargs               => $globalargs,
    modes_enabled            => $modes_enabled,
    modes_disabled           => $modes_disabled,
    servicegroups            => $servicegroups,
    check_title              => $check_title,
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    max_check_attempts       => $max_check_attempts,
    notification_period      => $notification_period,
    use                      => $use,
  }

}

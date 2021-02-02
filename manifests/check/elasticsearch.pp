class nagios::check::elasticsearch (
  $args                     = '',
  $host                     = undef,
  $port                     = undef,
  $node                     = undef,
  $modes_enabled            = [],
  $modes_disabled           = [],
  # Modes
  $args_cluster_status      = '',
  $args_jvm_usage           = '',
  $args_nodes               = '',
  $args_split_brain         = '',
  $args_unassigned_shards   = '',
  $check_title              = $::nagios::client::host_name,
  $check_period             = $::nagios::client::service_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::service_first_notification_delay,
  $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  $notification_period      = $::nagios::client::service_notification_period,
  $use                      = $::nagios::client::service_use,

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
    first_notification_delay => $notification_delay,
    max_check_attempts       => $max_check_attempts,
    notification_period      => $notification_period,
    use                      => $use,
  }

}

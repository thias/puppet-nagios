class nagios::check::rabbitmq (
  $ensure                       = undef,
  $package                      = $::nagios::params::python_request,
  # common args for all modes 'as-is' for the check script
  $args                         = '',
  # common args for all modes as individual parameters
  $user                         = undef,
  $pass                         = undef,
  $nodename                     = undef,
  $virtualhost                  = undef,
  # modes selectively enabled and/or disabled
  $modes_enabled                = [],
  $modes_disabled               = [],
  $args_connection_count        = '',
  $args_queues_count            = '',
  $args_mem_usage               = '',
  $args_aliveness               = '',
  $args_cluster_status          = '',
  # service
  $check_title              = $::nagios::client::host_name,
  $servicegroups            = 'rabbitmq',
  $check_period             = $::nagios::client::service_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::service_first_notification_delay,
  $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  $notification_period      = $::nagios::client::service_notification_period,
  $use                      = $::nagios::client::service_use,
) {

  nagios::client::nrpe_plugin { 'check_rabbitmq':
    ensure  => $ensure,
    package => $package,
  }

  # Set options from parameters unless already set inside args
  if $args !~ /-u/ and $user != undef {
    $arg_u = "-u ${user} "
  } else {
    $arg_u = ''
  }
  if $args !~ /-p/ and $pass != undef {
    $arg_p = "-p ${pass} "
  } else {
    $arg_p = ''
  }
  if $args !~ /-n/ and $nodename != undef {
    $arg_d = "-n ${nodename} "
  } else {
    $nodename_f = getvar('::nagios_rabbitmq_nodename')
    $arg_d = "-n ${nodename_f}"
  }
  if $args !~ /-v/ and $virtualhost != undef {
    $arg_c = "-v ${virtualhost} "
  } else {
    $arg_c = ''
  }
  $globalargs = strip("${arg_u}${arg_p}${arg_d}${arg_c}${args}")

  $modes = [
    'connection_count',
    'queues_count',
    'mem_usage',
    'aliveness',
    'cluster_status',
  ]
  nagios::check::rabbitmq::mode { $modes:
    ensure                   => $ensure,
    globalargs               => $globalargs,
    modes_enabled            => $modes_enabled,
    modes_disabled           => $modes_disabled,
    # service
    check_title              => $check_title,
    servicegroups            => $servicegroups,
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    max_check_attempts       => $max_check_attempts,
    notification_period      => $notification_period,
    use                      => $use,
  }

}

class nagios::check::disk (
  $ensure                   = undef,
  $args                     = '',
  # -l : Do not check network mounts, local (and checked) elsewhere
  # binfmt_misc : Denied by default, not useful to monitor
  # rpc_pipefs  : Denied by default, not useful to monitor
  # cgroup      : Denied by default, not useful to monitor
  $original_args            = '-l -X binfmt_misc -X rpc_pipefs -X cgroup',
  $check_title              = $::nagios::client::host_name,
  $servicegroups            = undef,
  $check_period             = $::nagios::client::service_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::first_notification_delay,
  $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  $notification_period      = $::nagios::client::service_notification_period,
  $use                      = $::nagios::client::service_use,
) inherits ::nagios::client {

  if $ensure != 'absent' {
    Package <| tag == 'nagios-plugins-disk' |>
  }

  # Include defaults if no overrides in $args
  if $args !~ /-w/ { $arg_w = '-w 5% ' } else { $arg_w = '' }
  if $args !~ /-c/ { $arg_c = '-c 2% ' } else { $arg_c = '' }
  $fullargs = strip("${original_args} ${arg_w}${arg_c}${args}")

  nagios::client::nrpe_file { 'check_disk':
    ensure => $ensure,
    args   => $fullargs,
  }

  nagios::service { "check_disk_${check_title}":
    ensure                   => $ensure,
    check_command            => 'check_nrpe_disk',
    service_description      => 'disk',
    servicegroups            => $servicegroups,
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    notification_period      => $notification_period,
    max_check_attempts       => $max_check_attempts,
    use                      => $use,
  }

}

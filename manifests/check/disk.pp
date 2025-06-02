class nagios::check::disk (
  $ensure                   = undef,
  $args                     = '',
  # -l : Do not check network mounts, local (and checked) elsewhere
  # Denied by default and not useful to monitor:
  # binfmt_misc
  # rpc_pipefs
  # cgroup /sys/fs/cgroup/*
  # tracefs /sys/kernel/debug/tracing
  # overlay /var/lib/docker/overlay2/<hash>/merged
  # nsfs /run/docker/netns/<hash>
  $original_args            = '-l -X binfmt_misc -X rpc_pipefs -X cgroup -X tracefs -X overlay -X nsfs',
  $check_title              = $::nagios::client::host_name,
  $servicegroups            = undef,
  $check_period             = $::nagios::client::service_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::service_first_notification_delay,
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
  # -A and -i must be after -w and -c
  # RHEL 10 /run/credentials/<foo>.service fail when they contain the "@" sign
  if ($facts['os']['family'] == 'RedHat' and versioncmp($facts['os']['release']['major'], '10') >= 0) {
    $arg_end = ' -A -i @'
  } else {
    $arg_end = ''
  }
  $fullargs = join([strip("${original_args} ${arg_w}${arg_c}${args}"),$arg_end])

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

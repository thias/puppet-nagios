class nagios::check::disk_projection (
  $ensure                   = 'present',
  $time_threshold           = 12,
  $exclude_fs               = 'tmpfs|devtmpfs|shm|efivarfs|binfmt_misc|rpc_pipefs|cgroup|tracefs|overlay|nsfs',
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
    file { '/usr/lib64/nagios/plugins/check_disk_usage_projection':
      ensure => $ensure,
      source => "puppet:///modules/${module_name}/scripts/check_disk_usage_projection",
      mode   => '0755',
      owner  => 'root',
      group  => 'root',
    }
  }

  $args = "--time ${time_threshold} --exclude \"${exclude_fs}\""

  nagios::client::nrpe_file { 'check_disk_usage_projection':
    ensure  => $ensure,
    args    => $args,
    require => File['/usr/lib64/nagios/plugins/check_disk_usage_projection'],
  }

  nagios::service { "check_disk_usage_projection_${check_title}":
    ensure                   => $ensure,
    check_command            => 'check_nrpe_disk_projection',
    service_description      => 'disk_usage_projection',
    servicegroups            => $servicegroups,
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    notification_period      => $notification_period,
    max_check_attempts       => $max_check_attempts,
    use                      => $use,
  }

}


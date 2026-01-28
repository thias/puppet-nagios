class nagios::check::disk_projection (
  Enum['present', 'absent'] $ensure                   = 'absent',
  Integer                   $warning_hours            = 24,
  Integer                   $critical_hours           = 12,
  Optional[String]          $exclude_fs               = 'tmpfs|devtmpfs|shm|efivarfs|binfmt_misc|rpc_pipefs|cgroup|tracefs|overlay|nsfs',
  Optional[String]          $check_title              = $::nagios::client::host_name,
  Optional[String]          $servicegroups            = undef,
  Optional[String]          $check_period             = $::nagios::client::service_check_period,
  Optional[String]          $contact_groups           = $::nagios::client::service_contact_groups,
  Optional[String]          $first_notification_delay = $::nagios::client::service_first_notification_delay,
  Optional[String]          $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  Optional[String]          $notification_period      = $::nagios::client::service_notification_period,
  Optional[String]          $use                      = $::nagios::client::service_use,
) inherits ::nagios::client {

  if $warning_hours <= $critical_hours {
    fail('nagios::check::disk_projection: warning_hours must be greater than critical_hours')
  }

  if $ensure == 'present' {
    ensure_packages(['bc','gawk'], { 'ensure' => 'installed' })
  }

  # Manage the check script file (remove when absent)
  file { '/usr/lib64/nagios/plugins/check_disk_usage_projection':
    ensure => $ensure ? {
      'present' => 'file',
      'absent'  => 'absent',
    },
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => $ensure ? {
      'present' => "puppet:///modules/${module_name}/scripts/check_disk_usage_projection",
      'absent'  => undef,
    },
  }

  # Define the NRPE command (remove when absent)
  nagios::client::nrpe_file { 'check_disk_usage_projection':
    ensure  => $ensure,
    args    => "-W ${warning_hours} -C ${critical_hours} --exclude \"${exclude_fs}\"",
    plugin  => 'check_disk_usage_projection',
    require => File['/usr/lib64/nagios/plugins/check_disk_usage_projection'],
  }

  # Define the Nagios service (remove when absent)
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
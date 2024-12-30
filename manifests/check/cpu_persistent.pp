class nagios::check::cpu_persistent (
  Enum['present', 'absent'] $ensure                   = 'present',
  Optional[String]          $args                     = '',
  Optional[String]          $check_title              = $::nagios::client::host_name,
  Optional[String]          $servicegroups            = undef,
  Optional[String]          $check_period             = $::nagios::client::service_check_period,
  Optional[String]          $contact_groups           = $::nagios::client::service_contact_groups,
  Optional[String]          $first_notification_delay = $::nagios::client::service_first_notification_delay,
  Optional[String]          $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  Optional[String]          $notification_period      = $::nagios::client::service_notification_period,
  Optional[String]          $use                      = $::nagios::client::service_use,
  Optional[String]          $warn                     = '70',
  Optional[String]          $crit                     = '85',
  Optional[String]          $warn_duration            = '3',
  Optional[String]          $crit_duration            = '5',
) inherits ::nagios::client {

  # Define regex patterns for case-insensitive matching
  $warn_regex = /-w|-W/
  $crit_regex = /-c|-C/
  $warn_dur_regex = /--warn_duration|--WARN_DURATION/
  $crit_dur_regex = /--crit_duration|--CRIT_DURATION/

  # Check each parameter and append defaults if missing
  if $args !~ $warn_regex and $warn != undef {
    $arg_w = "-w ${warn} "
  } else {
    $arg_w = ''
  }

  if $args !~ $crit_regex and $crit != undef {
    $arg_c = "-c ${crit} "
  } else {
    $arg_c = ''
  }

  if $args !~ $warn_dur_regex and $warn_duration != undef {
    $arg_warn_dur = "--warn_duration ${warn_duration} "
  } else {
    $arg_warn_dur = ''
  }

  if $args !~ $crit_dur_regex and $crit_duration != undef {
    $arg_crit_dur = "--crit_duration ${crit_duration} "
  } else {
    $arg_crit_dur = ''
  }

  # Combine all arguments
  $globalargs = strip("${arg_w}${arg_c}${arg_warn_dur}${arg_crit_dur}${args}")



  # Deploy the check script
  file { '/usr/lib64/nagios/plugins/check_cpu_persistent':
    ensure => $ensure,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => "puppet:///modules/${module_name}/scripts/check_cpu_persistent",
  }

  # Configure NRPE file for the new plugin
  nagios::client::nrpe_file { 'check_cpu_persistent':
    ensure  => $ensure,
    args    => $args,
    require => File['/usr/lib64/nagios/plugins/check_cpu_persistent'],
    plugin  => 'check_cpu_persistent',
  }

  # Define the Nagios service
  nagios::service { "check_cpu_persistent_${check_title}":
    ensure                   => $ensure,
    check_command            => 'check_nrpe_cpu_persistent',
    service_description      => 'cpu_persistent_usage',
    servicegroups            => $servicegroups,
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    notification_period      => $notification_period,
    max_check_attempts       => $max_check_attempts,
    use                      => $use,
  }
}
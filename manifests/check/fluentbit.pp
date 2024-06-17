class nagios::check::fluentbit (
  Enum['present','absent'] $ensure                   = 'present',
  Optional[String]         $args                     = '',
  Optional[String]         $check_title              = $::nagios::client::host_name,
  Optional[String]         $servicegroups            = undef,
  Optional[String]         $check_period             = $::nagios::client::service_check_period,
  Optional[String]         $contact_groups           = $::nagios::client::service_contact_groups,
  Optional[String]         $first_notification_delay = $::nagios::client::service_first_notification_delay,
  Optional[String]         $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  Optional[String]         $notification_period      = $::nagios::client::service_notification_period,
  Optional[String]         $use                      = $::nagios::client::service_use,
) inherits ::nagios::client {

  if $ensure != 'absent' {
    Package <| tag == 'nagios-plugins-fluentbit' |>
  }

  # Include defaults if no overrides in $args
  if $args !~ /-H/ { $arg_h = '-H localhost ' } else { $arg_h = '' }
  if $args !~ /-p/ { $arg_p = '-p 2020 '       } else { $arg_p = '' }
  $fullargs = strip("${arg_h}${arg_p}${args}")

  # Let's check if the fluentbit check script is present and if not copy it
  file { '/usr/lib64/nagios/plugins/check_fluentbit_health':
    ensure => $ensure,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => "puppet:///modules/${module_name}/scripts/check_fluentbit_health",
  }

  nagios::client::nrpe_file { 'check_fluentbit_health':
    ensure  => $ensure,
    args    => $fullargs,
    require => File['/usr/lib64/nagios/plugins/check_fluentbit_health'],
    plugin  => 'check_fluentbit_health',
  }

  nagios::service { "check_fluentbit_health_${check_title}":
    ensure                   => $ensure,
    check_command            => 'check_nrpe_fluentbit_health',
    service_description      => 'fluentbit_health',
    servicegroups            => $servicegroups,
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    notification_period      => $notification_period,
    max_check_attempts       => $max_check_attempts,
    use                      => $use,
  }

}  


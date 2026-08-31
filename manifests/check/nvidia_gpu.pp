class nagios::check::nvidia_gpu (
  Enum['present','absent'] $ensure                   = 'present',
  Optional[String]         $args                     = '',
  Integer                  $warning                  = 70,
  Integer                  $critical                 = 90,
  Enum['aggregate','single'] $mode                  = 'aggregate',
  Optional[Integer]        $gpu_index                = undef,
  Optional[String]         $check_title              = $::nagios::client::host_name,
  Optional[String]         $service_description      = undef,
  Optional[String]         $servicegroups            = undef,
  Optional[String]         $check_period             = $::nagios::client::service_check_period,
  Optional[String]         $contact_groups           = $::nagios::client::service_contact_groups,
  Optional[String]         $first_notification_delay = $::nagios::client::service_first_notification_delay,
  Optional[String]         $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  Optional[String]         $notification_period      = $::nagios::client::service_notification_period,
  Optional[String]         $use                      = $::nagios::client::service_use,
) inherits ::nagios::client {

  if $mode == 'single' and $gpu_index == undef and $args !~ /(^|\s)-i(\s|$)/ {
    fail('nagios::check::nvidia_gpu: gpu_index must be set when mode=single unless -i is already provided in args')
  }

  # Build defaults unless explicitly overridden in $args
  if $args !~ /(^|\s)-w(\s|$)/ { $arg_w = "-w ${warning} " } else { $arg_w = '' }
  if $args !~ /(^|\s)-c(\s|$)/ { $arg_c = "-c ${critical} " } else { $arg_c = '' }
  if $args !~ /(^|\s)-m(\s|$)/ { $arg_m = "-m ${mode} " }     else { $arg_m = '' }

  if $gpu_index != undef and $args !~ /(^|\s)-i(\s|$)/ {
    $arg_i = "-i ${gpu_index} "
  } else {
    $arg_i = ''
  }

  $fullargs = strip("${arg_w}${arg_c}${arg_m}${arg_i}${args}")

  if $service_description == undef {
    if $mode == 'single' and $gpu_index != undef {
      $real_service_description = "nvidia_gpu_${gpu_index}"
    } else {
      $real_service_description = 'nvidia_gpu'
    }
  } else {
    $real_service_description = $service_description
  }

  file { '/usr/lib64/nagios/plugins/check_nvidia_gpu':
    ensure => $ensure,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => "puppet:///modules/${module_name}/scripts/check_nvidia_gpu",
  }

  nagios::client::nrpe_file { 'check_nvidia_gpu':
    ensure  => $ensure,
    args    => $fullargs,
    require => File['/usr/lib64/nagios/plugins/check_nvidia_gpu'],
    plugin  => 'check_nvidia_gpu',
  }

  nagios::service { "check_nvidia_gpu_${check_title}":
  ensure                   => $ensure,
  check_command            => 'check_nrpe_nvidia_gpu',
  service_description      => $real_service_description,
  servicegroups            => $servicegroups,
  check_period             => $check_period,
  contact_groups           => $contact_groups,
  first_notification_delay => $first_notification_delay,
  notification_period      => $notification_period,
  max_check_attempts       => $max_check_attempts,
  use                      => $use,
  }
}
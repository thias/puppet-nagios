class nagios::check::hpsa (
  $ensure                   = undef,
  $args                     = '',
  $pkg                      = true,
  $check_title              = $::nagios::client::host_name,
  $servicegroups            = undef,
  $check_period             = $::nagios::client::service_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::first_notification_delay,
  $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  $notification_period      = $::nagios::client::service_notification_period,
  $use                      = $::nagios::client::service_use,
) {

  # The check is being executed via sudo
  file { "/etc/sudoers.d/nagios_check_hpsa":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    # We customize the user, the nagios plugin dir and few other things
    content => template("${module_name}/plugins/hpsa-sudoers.erb"),
  }

  # Service specific script, taken from:
  file { "${nagios::client::plugin_dir}/check_hpsa":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template("${module_name}/plugins/check_hpsa"),
  }

  # Optional package containing the script
  if $pkg {
    $pkgname = 'hpssacli'
    $pkgensure = $ensure ? {
      'absent' => 'absent',
      default  => 'installed',
    }
    ensure_packages($pkgname,{'ensure' => $pkgensure })

    # Required plugin
    if $pkgensure != 'absent' {
      Package <| tag == 'nagios-plugins-perl' |>
    }
  }

  nagios::client::nrpe_file { 'check_hpsa':
    ensure => $ensure,
    args   => $args,
  }

  nagios::service { "check_hpsa_${check_title}":
    ensure                   => $ensure,
    check_command            => 'check_nrpe_hpsa',
    service_description      => 'hpsa',
    servicegroups            => $servicegroups,
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    notification_period      => $notification_period,
    max_check_attempts       => $max_check_attempts,
    use                      => $use,
  }
}

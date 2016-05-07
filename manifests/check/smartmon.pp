class nagios::check::smartmon (
  $package                  = "smartmontools",
  $ensure                   = undef,
  $args                     = '',
  $check_title              = $::nagios::client::host_name,
  $servicegroups            = undef,
  $check_period             = $::nagios::client::service_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::first_notification_delay,
  $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  $notification_period      = $::nagios::client::service_notification_period,
  $use                      = $::nagios::client::service_use,
) {

  # Service specific script, taken from:
  file { "${nagios::client::plugin_dir}/check_smartmon":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template("${module_name}/plugins/check_smartmon"),
  }

  # The check is being executed via sudo
  file { "/etc/sudoers.d/nagios_check_smartmon":
    ensure => $ensure,
    owner  => 'root',
    group  => 'root',
    mode   => '0440',
    # We customize the user, the nagios plugin dir and few other things
    content => template("${module_name}/plugins/smartmon-sudoers.erb"),
  }

  ensure_packages($package)

  nagios::client::nrpe_file { "check_smartmon":
    ensure => $ensure,
    plugin => "check_smartmon",
    args   => '-d /dev/$ARG1$ -i $ARG2$',
  }

  $disks = $::nagios_smartmon
  $defaults = {
    ensure => $ensure,
  }
  # Generate resources for each physical disk
  create_resources(nagios::check::smartmon::disk, $disks, $defaults)
  
}

class nagios::check::ssd (
  $ensure                   = undef,
  $args                     = '',
  $package                  = [ 'bc', 'smartmontools', 'pciutils', 'lsscsi', 'nvme-cli' ],
  $vendor_package           = undef,
  $check_title              = $::nagios::client::host_name,
  $servicegroups            = undef,
  $check_period             = $::nagios::client::service_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::service_first_notification_delay,
  $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  $notification_period      = $::nagios::client::service_notification_period,
  $use                      = $::nagios::client::service_use,
) {

  # Install vendor specific package of storcli
  if $ensure != 'absent' {
    if $vendor_package {
      ensure_packages($vendor_package)
    } elsif $::bios_vendor == 'Dell Inc.' {
      # Assuming DELL server only have PERC cards >.<
      ensure_packages('perccli')
    } else {
      ensure_packages('storcli')
    }
  }

  # Sudoers file for priviledged commands
  file { '/etc/sudoers.d/nagios_check_ssd':
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    # We customize the user, the nagios plugin dir and few other things
    content => template('nagios/plugins/check_ssd-sudoers.erb'),
  }

  nagios::client::nrpe_plugin { 'check_ssd':
    ensure  => $ensure,
    # Main LSI package and command, used by the check script
    package => $package,
  }

  nagios::client::nrpe_file { 'check_ssd':
    ensure => $ensure,
    args   => $args,
  }

  nagios::service { "check_ssd_${check_title}":
    ensure                   => $ensure,
    check_command            => 'check_nrpe_ssd',
    service_description      => 'ssd',
    servicegroups            => $servicegroups,
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    notification_period      => $notification_period,
    max_check_attempts       => $max_check_attempts,
    use                      => $use,
  }

}

class nagios::check::postgres (
  $args                     = undef,
  $check_period             = undef,
  $first_notification_delay = undef,
  $notification_period      = undef,
  $modes_enabled            = [],
  $modes_disabled           = [],
  $pkg                      = true,
  $ensure                   = undef,
  $standby_mode             = false,
  $privileged_user          = 'postgres',
  $plugin                   = 'check_postgres',
  # Modes
  $args_backends = '',
  $args_bloat    = '',
) {

  # Generic overrides
  if $check_period {
    Nagios_service { check_period => $::nagios_check_postgres_period }
  }
  if $first_notification_delay {
    Nagios_service { first_notification_delay => $::nagios_check_postgres_first_notification_delay }
  }
  if $notification_period {
    Nagios_service { notification_period => $::nagios_check_postgres_notification_period }
  }

  # The check executes MegaCli using sudo
  file { '/etc/sudoers.d/nagios_check_postgres':
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    # We customize the user and the nagios plugin dir
    content => template('nagios/plugins/check_postgres-sudoers.erb'),
  }

  # Optional package containing the script
  if $pkg {
    $pkgname = 'nagios-plugins-postgres'
    $pkgensure = $ensure ? {
      'absent' => 'absent',
      default  => 'installed',
    }
    package { $pkgname: ensure => $pkgensure }
  }

  Package <| tag == 'nagios-plugins-perl' |>

  nagios::check::postgres::mode { [
    'backends',
    'bloat',
  ]:
  }

}


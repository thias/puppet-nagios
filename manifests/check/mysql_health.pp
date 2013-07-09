class nagios::check::mysql_health (
  $args,
  $check_period        = undef,
  $notification_period = undef,  
  $modes_enabled       = [],
  $modes_disabled      = [],
  $pkg                 = true,
  $ensure              = undef,
  # Modes
  $args_connection_time = ''
) {

  # Generic overrides
  if $check_period {
    Nagios_service { check_period => $::nagios_check_mysql_health_check_period }
  }
  if $notification_period {
    Nagios_service { notification_period => $::nagios_check_mysql_health_notification_period }
  }

  # Optional package containing the script
  if $pkg {
    $pkgname = $::operatingsystem ? {
      'Gentoo' => 'net-analyzer/nagios-check_mysql_health',
       default => 'nagios-plugins-mysql_health',
    }
    package { $pkgname:
      ensure => $ensure ? {
        'absent' => 'absent',
         default => 'installed',
      }
    }
  }

  Package <| tag == 'nagios-plugins-perl' |>

  nagios::check::mysql_health::mode { [
    'connection-time',
  ]:
#    modes_enabled  => $modes_enabled,
#    modes_disabled => $modes_disabled,
#    ensure         => $ensure,
#    check_title    => $title,
  }

}


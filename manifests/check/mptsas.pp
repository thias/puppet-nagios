define nagios::check::mptsas (
  $ensure     = undef,
  $args       = undef,
  $pkg        = true,
  $lsiutilbin = '/usr/sbin/lsiutil',
) {

  # Generic overrides
  if $::nagios_check_mptsas_check_period != undef {
    Nagios_service { check_period => $::nagios_check_mptsas_check_period }
  }
  if $::nagios_check_mptsas_notification_period != undef {
    Nagios_service { notification_period => $::nagios_check_mptsas_notification_period }
  }

  # Service specific overrides
  if $::nagios_check_mptsas_args != undef {
    $fullargs = $::nagios_check_mptsas_args
  } else {
    $fullargs = $args
  }

  file { "${nagios::client::plugin_dir}/check_mptsas":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    # We customize the MegaCli path, plugin path
    content => template('nagios/plugins/check_mptsas.erb'),
  }
  # The check executes MegaCli using sudo
  file { '/etc/sudoers.d/nagios_check_mptsas':
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    # We customize the MegaCli path and the user
    content => template('nagios/plugins/check_mptsas-sudoers.erb'),
  }
  # Optional package containing MegaCli
  if $pkg {
    $pkgname = $::operatingsystem ? {
      'Gentoo' => 'sys-block/lsiutil',
      default  => 'lsiutil',
    }
    $pkgensure = $ensure ? {
      'absent' => 'absent',
      default  => 'installed',
    }
    package { $pkgname: ensure => $pkgensure }
  }

  Package <| tag == 'nagios-plugins-perl' |>

  nagios::client::nrpe_file { 'check_mptsas':
    ensure => $ensure,
    args   => $fullargs,
  }

  nagios::service { "check_mptsas_${title}":
    ensure              => $ensure,
    check_command       => 'check_nrpe_mptsas',
    service_description => 'mptsas',
    #servicegroups       => 'mptsas',
  }

}

define nagios::check::megaraid_sas (
  $ensure     = undef,
  $args       = undef,
  $pkg        = true,
  $megaclibin = $::nagios::params::megaclibin,
) {

  # Generic overrides
  if $::nagios_check_megaraid_sas_check_period != undef {
    Nagios_service { check_period => $::nagios_check_megaraid_sas_check_period }
  }
  if $::nagios_check_megaraid_sas_notification_period != undef {
    Nagios_service { notification_period => $::nagios_check_megaraid_sas_notification_period }
  }

  # Service specific overrides
  if $::nagios_check_megaraid_sas_args != undef {
    $fullargs = $::nagios_check_megaraid_sas_args
  } else {
    $fullargs = $args
  }

  file { "${nagios::client::plugin_dir}/check_megaraid_sas":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    # We customize the MegaCli path, plugin path
    content => template('nagios/plugins/check_megaraid_sas.erb'),
  }
  # The check executes MegaCli using sudo
  file { '/etc/sudoers.d/nagios_check_megaraid_sas':
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    # We customize the MegaCli path and the user
    content => template('nagios/plugins/check_megaraid_sas-sudoers.erb'),
  }
  # Optional package containing MegaCli
  if $pkg {
    $pkgname = $::operatingsystem ? {
      'Gentoo' => 'sys-block/megacli',
      default  => 'megacli',
    }
    if $::nagios_check_megaraid_sas_version != undef {
      $ensure_value = $::nagios_check_megaraid_sas_version
    } else {
      $ensure_value = 'installed'
    }
    $pkgensure = $ensure ? {
      'absent' => 'absent',
      default  => $ensure_value,
    }
    package { $pkgname: ensure => $pkgensure }
  }

  Package <| tag == 'nagios-plugins-perl' |>

  nagios::client::nrpe_file { 'check_megaraid_sas':
    ensure => $ensure,
    args   => $fullargs,
  }

  nagios::service { "check_megaraid_sas_${title}":
    ensure              => $ensure,
    check_command       => 'check_nrpe_megaraid_sas',
    service_description => 'megaraid_sas',
    #servicegroups       => 'megaraid_sas',
  }

}

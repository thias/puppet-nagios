# Define:
#
# Only meant to be called from check::mysql_health, and looking up
# many variables directly there.
#
define nagios::check::mysql_health::mode () {

  # We need the mode name with underscores
  $mode_u = regsubst($title,'-','_','G')

  # Get the variables we need
  $check_title    = $::nagios::client::host_name
  $args           = $::nagios::check::mysql_health::args
  $modes_enabled  = $::nagios::check::mysql_health::modes_enabled
  $modes_disabled = $::nagios::check::mysql_health::modes_disabled
  $ensure         = $::nagios::check::mysql_health::ensure

  # Get the args passed to the main class for our mode
  $args_mode = getvar("nagios::check::mysql_health::args_${mode_u}")

  if ( ( $modes_enabled == [] and $modes_disabled == [] ) or
       ( $modes_enabled != [] and $mode_u in $modes_enabled ) or
       ( $modes_disabled != [] and ! ( $mode_u in $modes_disabled ) ) )
  {
    nagios::client::nrpe_file { "check_mysql_health_${mode_u}":
      plugin => 'check_mysql_health',
      args   => "${args} --mode ${title} ${args_mode}",
      ensure => $ensure,
    }
    nagios::service { "check_mysql_health_${mode_u}_${check_title}":
      check_command       => "check_nrpe_mysql_health_${mode_u}",
      service_description => "mysql_health_${mode_u}",
      servicegroups       => 'mysql_health',
      ensure              => $ensure,
    }
  } else {
    nagios::client::nrpe_file { "check_mysql_health_${mode_u}":
      ensure => absent,
    }
    nagios::service { "check_mysql_health_${mode_u}_${check_title}":
      check_command => 'foo',
      ensure        => absent,
    }
  }

}


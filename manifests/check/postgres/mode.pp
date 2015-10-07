# Define:
#
# Only meant to be called from check::postgres, and looking up
# many variables directly there.
#
define nagios::check::postgres::mode () {

  $mode = $title

  # Get the variables we need
  $check_title     = $::nagios::client::host_name
  $args            = $::nagios::check::postgres::args
  $modes_enabled   = $::nagios::check::postgres::modes_enabled
  $modes_disabled  = $::nagios::check::postgres::modes_disabled
  $ensure          = $::nagios::check::postgres::ensure
  $standby_mode    = $::nagios::check::postgres::standby_mode
  $plugin          = $::nagios::check::postgres::plugin
  $privileged_user = $::nagios::check::postgres::privileged_user

  # Get the args passed to the main class for our mode
  $args_mode = getvar("nagios::check::postgres::args_${mode}")

  # Enable standby mode if needed
  if $standby_mode {
    $args_standby = '--assume-standby-mode'
  }

  if ( ( $modes_enabled == [] and $modes_disabled == [] ) or
    ( $modes_enabled != [] and $mode in $modes_enabled ) or
    ( $modes_disabled != [] and ! ( $mode in $modes_disabled ) ) )
  {
    nagios::client::nrpe_file { "check_postgres_${mode}":
      ensure    => $ensure,
      plugin    => $plugin,
      args      => "${args} --action=${title} ${args_mode} ${args_standby}",
      sudo      => true,
      sudo_user => $privileged_user,
    }
    nagios::service { "check_postgres_${mode}_${check_title}":
      ensure              => $ensure,
      check_command       => "check_nrpe_postgres_${mode}",
      service_description => "postgres_${mode}",
      servicegroups       => 'postgres',
    }
  } else {
    nagios::client::nrpe_file { "check_postgres_${mode}":
      ensure => 'absent',
    }
    nagios::service { "check_postgres_${mode}_${check_title}":
      ensure        => 'absent',
      check_command => 'foo',
    }
  }

}


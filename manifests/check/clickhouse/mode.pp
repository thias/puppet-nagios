# Define:
#
# Only meant to be called from check::clickhouse, and looking up
# many variables directly there.
#
define nagios::check::clickhouse::mode () {

  $mode = $title

  # Get the variables we need
  $ensure          = $::nagios::check::clickhouse::ensure
  $check_title     = $::nagios::client::host_name
  $args            = $::nagios::check::clickhouse::args
  $modes_enabled   = $::nagios::check::clickhouse::modes_enabled
  $modes_disabled  = $::nagios::check::clickhouse::modes_disabled
  $plugin          = $::nagios::check::clickhouse::plugin

  # Get the args passed to the main class for our mode
  $args_mode = getvar("nagios::check::clickhouse::args_${mode}")

  if ( ( $modes_enabled == [] and $modes_disabled == [] ) or
    ( $modes_enabled != [] and $mode in $modes_enabled ) or
    ( $modes_disabled != [] and ! ( $mode in $modes_disabled ) ) )
  {
    nagios::client::nrpe_file { "check_clickhouse_${mode}":
      ensure => $ensure,
      plugin => $plugin,
      args   => strip("${args} -m ${title} ${args_mode}"),
    }
    nagios::service { "check_clickhouse_${mode}_${check_title}":
      ensure              => $ensure,
      check_command       => "check_nrpe_clickhouse_${mode}",
      service_description => "clickhouse_${mode}",
      servicegroups       => 'clickhouse',
    }
  } else {
    nagios::client::nrpe_file { "check_clickhouse_${mode}":
      ensure => 'absent',
    }
    nagios::service { "check_clickhouse_${mode}_${check_title}":
      ensure        => 'absent',
      check_command => 'foo',
    }
  }

}


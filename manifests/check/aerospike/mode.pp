# Define:
#
# Only meant to be called from check::aerospike, and looking up many variables
# directly there.
#
define nagios::check::aerospike::mode () {

  $mode = $title

  # Get the variables we need
  $ensure          = $::nagios::check::aerospike::ensure
  $check_title     = $::nagios::client::host_name
  $args            = $::nagios::check::aerospike::args
  $modes_enabled   = $::nagios::check::aerospike::modes_enabled
  $modes_disabled  = $::nagios::check::aerospike::modes_disabled
  $plugin          = $::nagios::check::aerospike::plugin

  # Get the args passed to the main class for our mode
  $args_mode = getvar("nagios::check::aerospike::args_${mode}")

  if ( ( $modes_enabled == [] and $modes_disabled == [] ) or
    ( $modes_enabled != [] and $mode in $modes_enabled ) or
    ( $modes_disabled != [] and ! ( $mode in $modes_disabled ) ) )
  {
    nagios::client::nrpe_file { "check_aerospike_${mode}":
      ensure => $ensure,
      plugin => $plugin,
      args   => strip("${args} -s ${title} ${args_mode}"),
    }
    nagios::service { "check_aerospike_${mode}_${check_title}":
      ensure              => $ensure,
      check_command       => "check_nrpe_aerospike_${mode}",
      service_description => "aerospike_${mode}",
      servicegroups       => 'aerospike',
    }
  } else {
    nagios::client::nrpe_file { "check_aerospike_${mode}":
      ensure => 'absent',
    }
    nagios::service { "check_aerospike_${mode}_${check_title}":
      ensure        => 'absent',
      check_command => 'foo',
    }
  }

}


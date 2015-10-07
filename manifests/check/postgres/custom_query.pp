# Define:
#
# Only meant to be called from check::postgres, and looking up
# many variables directly there.
#
define nagios::check::postgres::custom_query () {

  $query_name = $title

  # Get the variables we need
  $check_title    = $::nagios::client::host_name
  $args           = $::nagios::check::postgres::args
  $ensure         = $::nagios::check::postgres::ensure
  $standby_mode   = $::nagios::check::postgres::standby_mode
  $plugin         = $::nagios::check::postgres::plugin
  $custom_queries = $::nagios::check::postgres::custom_queries
  $server         = $::nagios::client::server
  $nrpe_command   = $::nagios::params::nrpe_command
  $nrpe_options   = $::nagios::params::nrpe_options

  # Full nrpe command to run, with default options
  $nrpe = "${nrpe_command} ${nrpe_options}"

  # Get query variables from the hash
  if (!$custom_queries[$query_name][ensure]) {
    $query_ensure = 'present'
  }
  $query_code = $custom_queries[$query_name][query]
  if ($custom_queries[$query_name][valtype]) {
    $query_valtype = $custom_queries[$query_name][valtype]
    $query_valtype_arg = "--valtype=${query_valtype}"
  }
  if ($custom_queries[$query_name][warning]) {
    $query_warning = $custom_queries[$query_name][warning]
    $query_warning_arg = "-w '${query_warning}'"
  }
  if ($custom_queries[$query_name][critical]) {
    $query_critical = $custom_queries[$query_name][critical]
    $query_critical_arg =  "-c '${query_critical}'"
  }
  if ($custom_queries[$query_name][reverse] == true) {
    $query_reverse = '--reverse'
  }

  # Build arguments string
  $args_query = "--query='${query_code}' ${query_valtype_arg} ${query_warning_arg} ${query_critical_arg} ${query_reverse}"

  # Enable standby mode if needed
  if $standby_mode {
    $args_standby = '--assume-standby-mode'
  }

  if ($query_ensure == 'present') {
    nagios::client::nrpe_file { "check_postgres_cq_${query_name}":
      ensure    => $ensure,
      plugin    => $plugin,
      args      => "${args} --action=custom_query ${args_query} ${args_standby}",
      sudo      => true,
      sudo_user => 'postgres',
    }
    nagios::service { "check_postgres_cq_${query_name}_${check_title}":
      ensure              => $ensure,
      check_command       => "check_nrpe_postgres_cq_${query_name}",
      service_description => "postgres_cq_${query_name}",
      servicegroups       => 'postgres',
    }
    @@nagios_command { "check_nrpe_postgres_cq_${query_name}":
      command_line => "${nrpe} -c check_postgres_cq_${query_name}",
      tag          => regsubst($server,'^(.+)$','nagios-\1'),
    }
  } elsif ($query_ensure == 'absent') {
    nagios::client::nrpe_file { "check_postgres_cq_${query_name}":
      ensure => 'absent',
    }
    nagios::service { "check_postgres_cq_${query_name}_${check_title}":
      ensure        => 'absent',
      check_command => 'foo',
    }
  }

}



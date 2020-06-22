# Define a mysql_health check with mode sql
#
# Only meant to be called from check::mysql_health, looking up
# variables directly from there.
#
# IMPORTANT: need to create a nagios command manually for each query:
# nagios_command { 'check_nrpe_mysql_health_sql_<check_name>':
#   command_line => "${nrpe} -c check_mysql_health_sql_<check_name>",
# }
#
define nagios::check::mysql_health::custom_query {
  $client = $::nagios::client::host_name
  $args   = $::nagios::check::mysql_health::args
  $ensure = $::nagios::check::mysql_health::ensure
  $check  = $::nagios::check::mysql_health::custom_queries[$title]

  $query    = $check['query']
  $critical = Integer($check['critical'])
  $warning  = Integer($check['warning'])

  if $query.empty {
    fail('You must provide a value for the query parameter')
  }

  # Absent this check if parent mysql_health check is disabled
  if $ensure == 'absent' {
    $check_ensure = 'absent'
  } else {
    $check_ensure = $check['ensure'] in ['present','absent'] ? {
      true  => $check['ensure'],
      false => 'present',
    }
  }

  if $warning > 0 {
    $warning_arg = "--warning ${warning}"
  }
  if $critical > 0 {
    $critical_arg = "--critical ${critical}"
  }

  $check_args = strip("--name '${query}' --name2 '${title}' ${warning_arg} ${critical_arg}")

  nagios::client::nrpe_file { "check_mysql_health_sql_${title}":
    ensure => $check_ensure,
    plugin => 'check_mysql_health',
    args   => "${args} --mode sql ${check_args}",
  }
  nagios::service { "check_mysql_health_sql_${title}_${client}":
    ensure              => $check_ensure,
    check_command       => "check_nrpe_mysql_health_sql_${title}",
    service_description => "mysql_health_sql_${title}",
    servicegroups       => 'mysql_health',
  }
}


#
# Class to enable ClickHouse Proxy monitoring (using check_http nagios plugin)
#
class nagios::check::chproxy (
  Optional[String] $ensure                   = undef,
  Optional[String] $args                     = '',
  String           $host                     = 'localhost',
  Integer          $port                     = 9090,
  String           $uri                      = '/?query=show%20tables',
  Optional[String] $check_period             = undef,
  Optional[String] $first_notification_delay = undef,
  Optional[String] $notification_period      = undef,
) {

  # Generic overrides
  if $check_period {
    Nagios_service { check_period => $::nagios_check_clickhouse_period }
  }
  if $first_notification_delay {
    Nagios_service { first_notification_delay => $::nagios_check_clickhouse_first_notification_delay }
  }
  if $notification_period {
    Nagios_service { notification_period => $::nagios_check_clickhouse_notification_period }
  }

  # Set options from parameters unless already set inside args
  if $args !~ /-H/ {
    $arg_h = "-H ${host} "
  } else {
    $arg_h = ''
  }
  if $args !~ /-p/ {
    $arg_p = "-p ${port} "
  } else {
    $arg_p = ''
  }
  if $args !~ /-u/ {
    $arg_u = "-u \"${uri}\" "
  } else {
    $arg_u = ''
  }
  $globalargs = strip("${arg_h}${arg_p}${arg_u}${args}")

  nagios::check::http { 'chproxy':
    args                     => $globalargs,
    check_period             => $check_period,
    first_notification_delay => $first_notification_delay,
    notification_period      => $notification_period,
  }

}


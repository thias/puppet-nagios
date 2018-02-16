define nagios::check::redis_sentinel_mmasters (
  $ensure        = undef,
  $fqdn,
  $port,
  $args          = undef,
) {

  $master = $title
  $arg_domain = "-H ${fqdn} "
  $arg_port = "-p ${port} "
  $arg_master = "-m ${master} "

  $global_args = strip("!${arg_domain}${arg_master}${arg_port}${args}")

  nagios::service { "check_redis_sentinel_${fqdn}_${master}":
    check_command       => "check_redis_sentinel${global_args}",
    service_description => "redis_sentinel_${master}",
    servicegroups       => 'redis',
  }

}

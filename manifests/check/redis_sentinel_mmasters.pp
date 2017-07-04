define nagios::check::redis_sentinel_mmasters (
  $ensure                   = undef,
  $servicegroups            = 'redis',
  $port,
) {

  $master = $title
  $lan_fqdn = regsubst($::fqdn, '\.[a-z]{2,}$','.lan')
  $arg_domain = "-H ${lan_fqdn} "
  $arg_port = "-p ${port} "
  $arg_master = "-m ${master} "

  $global_args = strip("!${arg_domain}${arg_master}${arg_port}")

  nagios::service { "check_redis_sentinel_${lan_fqdn}_${master}":
    check_command       => "check_redis_sentinel${global_args}",
    service_description => "redis_sentinel_${master}",
    servicegroups       => 'redis',
  }

}

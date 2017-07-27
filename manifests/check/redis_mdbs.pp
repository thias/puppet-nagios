define nagios::check::redis_mdbs (
  $ensure = undef,
  $modes  = {},
  $pass   = undef,
  $port,
) {

  # Set options from parameters unless already set inside args
  $arg_db   = "-d ${title} "
  $arg_port = "-p ${port} "
  $lan_fqdn = regsubst($::fqdn, '\.[a-z]{2,}$','.lan')
  $arg_domain = "-H ${lan_fqdn} "

  if $pass != undef {
    $arg_pass = "-x ${pass} "
  } else {
    $arg_pass = ''
  }

  $modes.each |$mode, $args_mode| {
    if $args_mode {
      $args = $args_mode
    } else {
      $args = undef
    }
    case $mode {
      'hitrate', 'response_time', 'uptime_in_seconds': {
        $check_param = "-f --${mode}="
      }
      default: {
        $check_param = "--perfvars=${mode} --${mode}="
      }
    }
    $global_args = strip("!${arg_domain}${arg_db}${arg_port}${arg_pass}${check_param}${args}")

    nagios::service { "check_redis_mdbs_${lan_fqdn}_${title}_${mode}":
      check_command       => "check_redis${global_args}",
      service_description => "redis_${title}_${mode}",
      servicegroups       => 'redis',
    }
  }


}

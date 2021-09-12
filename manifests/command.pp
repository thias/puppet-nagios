# Define: nagios::command
#
# Wrap around the original nagios_command
# * To be able to export with the correct tag automatically
# * To be able to use defaults overridden or from facts
#
define nagios::command (
  $command_line,
  $ensure                   = undef,
  $server                   = $nagios::client::server,
  $host_name                = $nagios::client::host_name,
  $target                   = "/etc/nagios/puppet_checks.d/${host_name}.cfg",
) {

  # Support an array of tags for multiple nagios servers
  $service_tag = regsubst($server,'^(.+)$','nagios-\1')
  @@nagios_command { $title:
    ensure                   => $ensure,
    command_line             => $command_line,
    tag                      => $service_tag,
    target                   => $target,
    require                  => File[dirname($target)],
  }
  @@nagios::file_perm { $title:
    target => $target,
    tag    => $service_tag,
  }

}


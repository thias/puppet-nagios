define nagios::client::nrpe_plugin (
  $ensure    = 'present',
  $erb       = false,
  $perl      = false,
  $package   = false,
  $sudo_cmd  = undef,
  $sudo_user = 'root',
) {

  # The check executes some command(s) using sudo
  if $sudo_cmd {
    file { "/etc/sudoers.d/nagios_${title}":
      ensure  => $ensure,
      owner   => 'root',
      group   => 'root',
      mode    => '0440',
      content => template("${module_name}/sudoers-client-nrpe_plugin.erb"),
    }
  }

  # Nagios perl library required by checks written in perl
  if $perl == true and $ensure != 'absent' {
    Package <| tag == 'nagios-plugins-perl' |>
  }

  # System package(s) required by checks relying on 3rd party tools
  if $package != false and $ensure != 'absent' {
    ensure_packages($package)
  }

  # Service specific check script
  $suffix = $erb ? {
    true    => '.erb',
    default => '',
  }
  file { "${nagios::client::plugin_dir}/${title}":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template("${module_name}/plugins/${title}${suffix}"),
  }

}

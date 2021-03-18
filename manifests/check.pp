# This defined type is a placeholder for external nagios checks (defined from other modules)
# It allows parameters (direct, hiera and $nagios::client defaults, in this order)
# Check manifests/checks/dummy.pp for an example on how to use it

define nagios::check (
  $executable,
#  $parameters          = lookup("nagios::check::${title}::parameters"),
  $description         = lookup("nagios::check::${title}::description", undef, undef, $title),
  $nrpe_options        = lookup("nagios::check::${title}::nrpe_options", undef, undef, '-t 15'),
  $ensure              = lookup("nagios::check::${title}::ensure", undef, undef, 'present'),
#  $servicegroups       = lookup("nagios::check::${title}::description", undef, undef, []),
  $check_period        = lookup("nagios::check::${title}::check_period"),
  $contact_groups      = lookup("nagios::check::${title}::contact_groups"),
  $max_check_attempts  = lookup("nagios::check::${title}::max_check_attempts"),
  $notification_period = lookup("nagios::check::${title}::notification_period"),
  $use                 = lookup("nagios::check::${title}::use"),
) {

  # We need to take default values from the nagios::client config
  class { '::nagios::client': }

  # Some constants that don't deserve to be parameters
  $host_name           = $nagios::client::host_name
  $server              = $nagios::client::server

  # Review parameters to see if there is a better default (from nagios::client)
  $final_check_period = $check_period ? {
    undef   => $nagios::client::service_check_period,
    default => $check_period,
  }
  $final_contact_groups = $contact_groups ? {
    undef   => $nagios::client::service_contact_groups,
    default => $contact_groups,
  }
  $final_max_check_attempts = $max_check_attempts ? {
    undef   => $nagios::client::service_max_check_attempts,
    default => $max_check_attempts,
  }
  $final_notification_period = $notification_period ? {
    undef   => $nagios::client::service_notification_period,
    default => $notification_period,
  }
  $final_use = $use ? {
    undef   => $nagios::client::service_use,
    default => $use,
  }

  # Enable NRPE to execute it
  file { "${nagios::params::nrpe_cfg_dir}/nrpe-check-${title}.cfg":
    ensure  => $ensure,
    owner   => 'root',
    group   => $nagios::client::nrpe_group,
    mode    => '0640',
    content => "command[check_${title}]=${executable}\n",
    notify  => Service[$nagios::params::nrpe_service],
  }

  # Export the precious resource with all modified parameters
  @@nagios_service { "check_${title}_${host_name}":
    ensure              => $ensure,
    host_name           => $host_name,
    check_command       => "check_${title}",
    servicegroups       => $servicegroups, # lint:ignore:variable_scope
    service_description => $description,
    check_period        => $final_check_period,
    contact_groups      => $final_contact_groups,
    max_check_attempts  => $final_max_check_attempts,
    notification_period => $final_notification_period,
    use                 => $final_use,
    # Support an arrays of tags for multiple nagios servers
    tag                 => regsubst($server,'^(.+)$','nagios-\1'),
  }

  # Default line for nrpe invoke (used in the nagios_command)
  $nrpe = "\$USER1\$/check_nrpe -H \$HOSTADDRESS\$ ${nrpe_options}"

#  # NRPE parameters are a security risk, better disabled
#  $command_parameters = $parameters? {
#    undef   => '',
#    default => "-a $parameters",
#  }

  @@nagios_command { "check_${title}":
#   command_line => "${nrpe} -c check_${title} $command_parameters",
    command_line => "${nrpe} -c check_${title}",
    tag          => regsubst($server,'^(.+)$','nagios-\1'),
  }

}


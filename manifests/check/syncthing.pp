class nagios::check::syncthing (
  $ensure                   = undef,
  $package                  = getvar('::nagios::params::python_request'),
  # common args for all modes 'as-is' for the check script
  $args                     = '',
  # common args for all modes as individual parameters
  $api_key                  = undef,
  # modes selectively enabled and/or disabled
  $modes_enabled            = [],
  $modes_disabled           = [],
  $args_alive               = '',
  $args_devices             = '',
  $args_folder_status       = '',
  $args_last_scans          = '',

) {

  #if versioncmp($facts['os']['release']['major'], '8') >= 0 {
  #  $package = 'python3-requests'
  #} else {
  #  $package = 'python2-requests'
  #}

  nagios::client::nrpe_plugin { 'check_syncthing':
    ensure  => $ensure,
    package => $package,
  }

  # Set options from parameters unless already set inside args
  if $args !~ /-X/ and $api_key != undef {
    $arg_x = "-X ${api_key} "
  } else {
    $arg_x = ''
  }

  $globalargs = strip("-H localhost ${arg_x}${args}")

  $modes = [
    'alive',
    'devices',
    'folders_status',
    'last_scans',
  ]
  nagios::check::syncthing::mode { $modes:
  }

}

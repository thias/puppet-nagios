define nagios::check::elasticsearch::mode (
    $ensure,
    $globalargs,
    $modes_enabled,
    $modes_disabled,
    $servicegroups,
    $check_title,
    $check_period,
    $contact_groups,
    $first_notification_delay,
    $max_check_attempts,
    $notification_period,
    $use,
) {
  $mode = $title
  if $ensure == 'absent' or
  ( $modes_disabled != [] and $mode in $modes_disabled ) or
  ( $modes_enabled != [] and ! ( $mode in $modes_enabled ) ) {

    $ensure_mode = 'absent'
    $fullargs = undef

  } else {
    $ensure_mode = $ensure
    # Get the args passed to the main class for our mode
    $args_mode = getvar("::nagios::check::elasticsearch::args_${mode}")
    if $mode == 'split_brain' {
      # split_brain mode needs the node address through'-N', '-H' option is not need it 
      # since the query output already answer with the full cluster status
      $fullargs = regsubst(strip("${globalargs} ${args_mode}"),'-H','-N')
    } else {
      $fullargs = strip("${globalargs} ${args_mode}")
    }
  }

  nagios::client::nrpe_file { "check_elasticsearch_${mode}":
    ensure => $ensure_mode,
    plugin => "check_es_${mode}",
    args   => $fullargs,
  }

  nagios::service { "check_elasticsearch_${mode}_${check_title}":
    ensure                   => $ensure_mode,
    check_command            => "check_nrpe_elasticsearch_${mode}",
    service_description      => "elasticsearch_${mode}",
    servicegroups            => $servicegroups,
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    notification_period      => $notification_period,
    max_check_attempts       => $max_check_attempts,
    use                      => $use,
  }

}

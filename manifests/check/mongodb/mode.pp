# Definition only meant to be called from check::mongodb, once for each mode
#
define nagios::check::mongodb::mode (
  $ensure,
  $globalargs,
  $modes_enabled,
  $modes_disabled,
  # service
  $check_title,
  $servicegroups,
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

  } else {

    $ensure_mode = $ensure

    # Get the args passed to the main class for our mode
    $args_mode = getvar("::nagios::check::mongodb::args_${mode}")
    $fullargs = strip("${globalargs} -A ${title} ${args_mode}")

  }

  nagios::client::nrpe_file { "check_mongodb_${mode}":
    ensure => $ensure_mode,
    plugin => 'check_mongodb',
    args   => $fullargs,
  }

  nagios::service { "check_mongodb_${mode}_${check_title}":
    ensure                   => $ensure_mode,
    check_command            => "check_nrpe_mongodb_${mode}",
    service_description      => "mongodb_${mode}",
    servicegroups            => $servicegroups,
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    notification_period      => $notification_period,
    max_check_attempts       => $max_check_attempts,
    use                      => $use,
  }

}

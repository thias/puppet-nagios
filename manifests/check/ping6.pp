class nagios::check::ping6 (
  $ensure                   = undef,
  $args                     = '',
  $address6                 = $::nagios_ipaddress6,
  $check_title              = $::nagios::client::host_name,
  $servicegroups            = undef,
  $check_period             = $::nagios::client::service_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::first_notification_delay,
  $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  $notification_period      = $::nagios::client::service_notification_period,
  $use                      = $::nagios::client::service_use,
) inherits ::nagios::client {

  if $address6 or $args =~ /-H/ {

    # Include defaults if no overrides in $args
    if $args !~ /-H/ { $arg_h = "-H ${address6} " } else { $arg_h = '' }
    if $args !~ /-w/ { $arg_w = '-w 2000,50% ' }    else { $arg_w = '' }
    if $args !~ /-c/ { $arg_c = '-c 5000,100% ' }   else { $arg_c = '' }
    if $args !~ /-p/ { $arg_p = '-p 5 ' }           else { $arg_p = '' }
    $fullargs = strip("${arg_h}${arg_w}${arg_c}${arg_p}${args}")

    nagios::service { "check_ping6_${check_title}":
      ensure                   => $ensure,
      check_command            => "check_ping6!${fullargs}",
      service_description      => 'ping6',
      servicegroups            => $servicegroups,
      check_period             => $check_period,
      contact_groups           => $contact_groups,
      first_notification_delay => $first_notification_delay,
      max_check_attempts       => $max_check_attempts,
      notification_period      => $notification_period,
      use                      => $use,
    }

  }

}

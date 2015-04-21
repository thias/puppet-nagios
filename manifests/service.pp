# Define: nagios::service
#
# Wrap around the original nagios_service
# * To be able to export with the correct tag automatically
# * To be able to use defaults overridden or from facts
#
define nagios::service (
  $check_command,
  $ensure                   = undef,
  $server                   = $nagios::client::server,
  $host_name                = $nagios::client::host_name,
  $service_description      = $name,
  $servicegroups            = undef,
  $check_period             = $nagios::client::service_check_period,
  $contact_groups           = $nagios::client::service_contact_groups,
  $first_notification_delay = $nagios::client::service_first_notification_delay,
  $max_check_attempts       = $nagios::client::service_max_check_attempts,
  $notification_period      = $nagios::client::service_notification_period,
  $use                      = $nagios::client::service_use,
) {

  # Work around being passed undefined variables resulting in ''
  $final_check_period = $check_period ? {
    ''      => $nagios::client::service_check_period,
    undef   => $nagios::client::service_check_period,
    default => $check_period,
  }
  $final_max_check_attempts = $max_check_attempts ? {
    ''      => $nagios::client::service_max_check_attempts,
    undef   => $nagios::client::service_max_check_attempts,
    default => $max_check_attempts,
  }
  $final_notification_period = $notification_period ? {
    ''      => $nagios::client::service_notification_period,
    undef   => $nagios::client::service_notification_period,
    default => $notification_period,
  }
  $final_use = $use ? {
    ''      => $nagios::client::service_use,
    undef   => $nagios::client::service_use,
    default => $use,
  }

  # Support an array of tags for multiple nagios servers
  $service_tag = regsubst($server,'^(.+)$','nagios-\1')
  @@nagios_service { $title:
    ensure                   => $ensure,
    host_name                => $host_name,
    check_command            => $check_command,
    service_description      => $service_description,
    servicegroups            => $servicegroups,
    check_period             => $final_check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    max_check_attempts       => $final_max_check_attempts,
    notification_period      => $final_notification_period,
    use                      => $final_use,
    tag                      => $service_tag,
  }

}


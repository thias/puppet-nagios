# Class: nagios::client::defaults
#
# Default values for the clients, meant to be overridden using hiera
# automatic class parameters lookups.
#
class nagios::client::defaults (
  $check_period        = undef,
  $max_check_attempts  = undef,
  $notification_period = undef,
  $use                 = undef,
) {
}


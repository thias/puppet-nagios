# Define:
#
# Only meant to be called from check::zookeeper, and looking up
# many variables directly there.
#

define nagios::check::zookeeper::key () {

  $key = $title

  # Get the variables we need
  $check_title   = $::nagios::client::host_name
  $args          = $::nagios::check::zookeeper::args
  $keys_enabled  = $::nagios::check::zookeeper::keys_enabled
  $keys_disabled = $::nagios::check::zookeeper::keys_disabled
  $ensure        = $::nagios::check::zookeeper::ensure
  $leader        = $::nagios::check::zookeeper::leader
  $plugin        = $::nagios::check::zookeeper::plugin

  # Get the args passed to the main class for our key
  $args_key = getvar("nagios::check::zookeeper::args_${key}")

  # Disable follower only keys if needed
  if $leader == false {
    $keys_disabled_final = concat($keys_disabled, 'zk_pending_syncs', 'zk_synced_followers')
  } else {
    $keys_disabled_final = $keys_disabled
  }

  if ( ( $keys_enabled == [] and $keys_disabled_final == [] ) or
    ( $keys_enabled != [] and $key in $keys_enabled ) or
    ( $keys_disabled_final != [] and ! ( $key in $keys_disabled_final ) ) )
  {
    nagios::client::nrpe_file { "check_${key}":
      ensure => $ensure,
      plugin => $plugin,
      args   => "${args} --output=nagios --key=${title} ${args_key}",
    }
    nagios::service { "check_${key}_${check_title}":
      ensure              => $ensure,
      check_command       => "check_nrpe_${key}",
      service_description => "${key}",
      servicegroups       => 'zookeeper',
    }
  } else {
    nagios::client::nrpe_file { "check_${key}":
      ensure => 'absent',
    }
    nagios::service { "check_${key}_${check_title}":
      ensure        => 'absent',
      check_command => 'foo',
    }
  }

}


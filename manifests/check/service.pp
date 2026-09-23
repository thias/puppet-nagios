define nagios::check::service (
  $ensure                   = undef,
  $check_title              = $::nagios::client::host_name,
  $servicegroups            = undef,
  $check_period             = $::nagios::client::service_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::service_first_notification_delay,
  $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  $notification_period      = $::nagios::client::service_notification_period,
  $use                      = $::nagios::client::service_use,
  $systemd_user             = undef,
  $journal_pattern          = undef,
  $journal_lookback         = '10min',
) {

  ensure_resource(
    'nagios::client::nrpe_plugin',
    'check_service',
    {'ensure' => $ensure},
  )

  $nrpe_command = $::nagios::params::nrpe_command
  $nrpe_options = $::nagios::params::nrpe_options
  $nrpe         = "${nrpe_command} ${nrpe_options}"

  $service_args = $systemd_user ? {
    undef   => "-s ${title}",
    default => "-s ${title} -U ${systemd_user}",
  }

  if $systemd_user {
    # Install the helper used to connect directly to the target user's
    # systemd --user manager.
    ensure_resource(
      'nagios::client::nrpe_plugin',
      'check_systemd_user_service',
      {'ensure' => $ensure},
    )

    # Use nrpe_plugin's existing sudoers support to grant only the exact
    # service check to NRPE, running as the target systemd user.
    #
    # plugin_template => false makes this a sudoers-only resource; the
    # actual helper is installed once above.
    nagios::client::nrpe_plugin { "systemd_user_service_${title}":
      ensure          => $ensure,
      plugin_template => false,
      sudo_user       => $systemd_user,
      sudo_cmd        => "${::nagios::client::plugin_dir}/check_systemd_user_service ${title}",
    }
  }

  @@nagios_command { "check_nrpe_service_${title}_${facts['networking']['fqdn']}":
    command_line => "${nrpe} -c check_service_${title}",
    tag          => 'service',
  }

  nagios::client::nrpe_file { "check_service_${title}":
    ensure => $ensure,
    args   => $service_args,
    plugin => 'check_service',
  }

  nagios::service { "check_service_${title}_${::nagios::client::host_name}":
    ensure                   => $ensure,
    check_command            => "check_nrpe_service_${title}_${facts['networking']['fqdn']}",
    service_description      => "service_${title}",
    servicegroups            => $servicegroups,
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    notification_period      => $notification_period,
    max_check_attempts       => $max_check_attempts,
    use                      => $use,
  }

  if $journal_pattern {
    ensure_resource(
      'nagios::client::nrpe_plugin',
      'check_systemd_journal',
      {'ensure' => $ensure},
    )

    if $systemd_user {
      # Impersonate `$systemd_user` to run `check_systemd_journal` via a narrow
      # sudoers grant.
      # Note: Sudoers `Cmnd_Spec` ignores shell quoting, so literal spaces must
      # be backslash-escaped (`word\ with\ spaces`) to match at runtime; standard
      # quotes pass `visudo` but silently fail.
      $journal_pattern_sudoers_safe = regsubst($journal_pattern, ' ', '\ ', 'G')

      nagios::client::nrpe_plugin { "systemd_journal_${title}":
        ensure          => $ensure,
        plugin_template => false,
        sudo_user       => $systemd_user,
        sudo_cmd        => "${::nagios::client::plugin_dir}/check_systemd_journal user ${title} ${journal_lookback} ${journal_pattern_sudoers_safe}",
      }

      # Unlike sudo_cmd above, this DOES go through a real shell so
      # normal double-quote grouping is correct and unchanged here.
      $journal_args = "-s ${title} -U ${systemd_user} -J \"${journal_pattern}\" -L ${journal_lookback}"
    } else {
      # Plain system-wide unit: no user to impersonate, so no sudoers grant at all
      $journal_args = "-s ${title} -J \"${journal_pattern}\" -L ${journal_lookback}"
    }

    @@nagios_command { "check_nrpe_service_${title}_journal_${facts['networking']['fqdn']}":
      command_line => "${nrpe} -c check_service_${title}_journal",
      tag          => 'service',
    }

    nagios::client::nrpe_file { "check_service_${title}_journal":
      ensure => $ensure,
      args   => $journal_args,
      plugin => 'check_service',
    }

    nagios::service { "check_service_${title}_journal_${::nagios::client::host_name}":
      ensure                   => $ensure,
      check_command            => "check_nrpe_service_${title}_journal_${facts['networking']['fqdn']}",
      service_description      => "service_${title}_journal",
      servicegroups            => $servicegroups,
      check_period             => $check_period,
      contact_groups           => $contact_groups,
      first_notification_delay => $first_notification_delay,
      notification_period      => $notification_period,
      max_check_attempts       => $max_check_attempts,
      use                      => $use,
    }
  }
}

# Class: nagios::client
#
# This is the main class to be included on all nodes to be monitored by nagios.
#
class nagios::client (
  $nagios_host_name            = $::nagios_host_name,
  $nagios_server               = $::nagios_server,
  # nrpe.cfg
  $nrpe_log_facility           = 'daemon',
  $nrpe_pid_file               = $nagios::params::nrpe_pid_file,
  $nrpe_server_port            = '5666',
  $nrpe_server_address         = undef,
  $nrpe_user                   = $nagios::params::nrpe_user,
  $nrpe_group                  = $nagios::params::nrpe_group,
  $nrpe_allowed_hosts          = '127.0.0.1',
  $nrpe_dont_blame_nrpe        = '0',
  $nrpe_command_prefix         = undef,
  $nrpe_debug                  = '0',
  $nrpe_command_timeout        = '60',
  $nrpe_connection_timeout     = '300',
  # host defaults
  $host_address                = $::nagios_host_address,
  $host_address6               = $::nagios_host_address6,
  $host_alias                  = $::nagios_host_alias,
  $host_check_period           = $::nagios_host_check_period,
  $host_check_command          = $::nagios_host_check_command,
  $host_contact_groups         = $::nagios_host_contact_groups,
  $host_hostgroups             = $::nagios_host_hostgroups,
  $host_notes                  = $::nagios_host_notes,
  $host_notes_url              = $::nagios_host_notes_url,
  $host_notification_period    = $::nagios_host_notification_period,
  $host_use                    = $::nagios_host_use,
  # service defaults (hint: use host_* or override only service_use for efficiency)
  $service_check_period        = $::nagios_service_check_period,
  $service_contact_groups      = $::nagios_service_contact_groups,
  $service_max_check_attempts  = $::nagios_service_max_check_attempts,
  $service_notification_period = $::nagios_service_notification_period,
  $service_use                 = 'generic-service',
  # other
  $plugin_dir                  = $nagios::params::plugin_dir,
  $selinux                     = true
) inherits ::nagios::params {

  # Set the variables to be used, including scoped from elsewhere, based on
  # the optional fact or parameter from here
  $host_name = $nagios_host_name ? {
    ''      => $::fqdn,
    undef   => $::fqdn,
    default => $nagios_host_name,
  }
  $server = $nagios_server ? {
    ''      => 'default',
    undef   => 'default',
    default => $nagios_server,
  }

  # Base package(s)
  package { $nagios::params::nrpe_package:
    ensure => 'installed',
    alias  => $nagios::params::nrpe_package_alias,
  }

  # Most plugins use nrpe, so we install it everywhere
  service { $nagios::params::nrpe_service:
    ensure    => 'running',
    enable    => true,
    hasstatus => true,
    subscribe => File[$nagios::params::nrpe_cfg_file],
  }
  file { $nagios::params::nrpe_cfg_file:
    owner   => 'root',
    group   => $nrpe_group,
    mode    => '0640',
    content => template('nagios/nrpe.cfg.erb'),
    require => Package['nrpe']
  }
  # Included in the package, but we need to enable purging
  file { $nagios::params::nrpe_cfg_dir:
    ensure  => 'directory',
    owner   => 'root',
    group   => $nrpe_group,
    mode    => '0750',
    purge   => true,
    recurse => true,
    require => Package['nrpe'],
  }
  # Create resource for the check_* parent resource
  file { $nagios::client::plugin_dir:
    ensure  => 'directory',
    require => Package['nrpe'],
  }

  # Where to store configuration for our custom nagios_* facts
  file { '/etc/nagios/facter':
    ensure  => 'directory',
    purge   => true,
    recurse => true,
    require => Package['nrpe'],
  }

  # The initial fact, to be used to know if a node is a nagios client
  nagios::client::config { 'client': value => 'true' }

  # The main nagios_host entry
  nagios::host { $host_name:
    server              => $server,
    address             => $host_address,
    host_alias          => $host_alias,
    check_period        => $host_check_period,
    check_command       => $host_check_command,
    contact_groups      => $host_contact_groups,
    hostgroups          => $host_hostgroups,
    notes               => $host_notes,
    notes_url           => $host_notes_url,
    notification_period => $host_notification_period,
    use                 => $host_use,
  }

  # TODO: Remove once all check/*.pp files are updated
  Nagios_service {
    use => 'generic-service,nagiosgraph-service',
  }

  # Enable all default checks by... default
  # Old style with facts overrides
  class { '::nagios::defaultchecks': }
  # New style with hiera overrides
  class { '::nagios::check::conntrack': }
  class { '::nagios::check::cpu': }
  class { '::nagios::check::load': }
  class { '::nagios::check::ntp_time': }
  class { '::nagios::check::ping6': }
  class { '::nagios::check::ram': }
  class { '::nagios::check::swap': }
  if $::nagios_mysqld {
    case $::operatingsystem {
      'RedHat', 'Fedora', 'CentOS', 'Scientific', 'Amazon': {
        class { '::nagios::check::mysql_health': }
      }
      'Debian', 'Ubuntu': {
        # nagios-plugins-mysql_health doesn't exist for Trusty
        # https://launchpad.net/ubuntu/trusty/+search?text=nagios-plugins
      }
      default: {
        class { '::nagios::check::mysql_health': }
      }
    }
  }
  if $::nagios_memcached {
    class { '::nagios::check::memcached': }
  }
  if $::nagios_postgres {
    class { '::nagios::check::postgres': }
  }

  # With selinux, some nrpe plugins require additional rules to work
  if $selinux and $::selinux_enforced {
    selinux::audit2allow { 'nrpe':
      source => "puppet:///modules/${module_name}/messages.nrpe",
    }
  }

}


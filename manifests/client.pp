# Class: nagios::client
#
# This is the main class to be included on all nodes to be monitored by nagios.
#
class nagios::client (
  $nagios_host_name                 = getvar('::nagios_host_name'),
  $nagios_server                    = getvar('::nagios_server'),
  # nrpe
  $nrpe_package                     = $::nagios::params::nrpe_package,
  $nrpe_package_alias               = $::nagios::params::nrpe_package_alias,
  $nrpe_cfg_file                    = $::nagios::params::nrpe_cfg_file,
  $nrpe_service                     = $::nagios::params::nrpe_service,
  $nrpe_cfg_dir                     = $::nagios::params::nrpe_cfg_dir,
  # nrpe.cfg
  $nrpe_log_facility                = 'daemon',
  $nrpe_pid_file                    = $::nagios::params::nrpe_pid_file,
  $nrpe_server_port                 = '5666',
  $nrpe_server_address              = undef,
  $nrpe_user                        = $::nagios::params::nrpe_user,
  $nrpe_group                       = $::nagios::params::nrpe_group,
  $nrpe_allowed_hosts               = '127.0.0.1',
  $nrpe_dont_blame_nrpe             = '0',
  $nrpe_command_prefix              = undef,
  $nrpe_debug                       = '0',
  $nrpe_command_timeout             = '60',
  $nrpe_connection_timeout          = '300',
  # host defaults
  $host_address                     = getvar('::nagios_host_address'),
  $host_address6                    = getvar('::nagios_host_address6'),
  $host_alias                       = getvar('::nagios_host_alias'),
  $host_check_period                = getvar('::nagios_host_check_period'),
  $host_check_command               = getvar('::nagios_host_check_command'),
  $host_contact_groups              = getvar('::nagios_host_contact_groups'),
  $host_hostgroups                  = getvar('::nagios_host_hostgroups'),
  $host_notes                       = getvar('::nagios_host_notes'),
  $host_notes_url                   = getvar('::nagios_host_notes_url'),
  $host_notification_period         = getvar('::nagios_host_notification_period'),
  $host_use                         = getvar('::nagios_host_use'),
  # service defaults (hint: use host_* or override only service_use
  # for efficiently affecting all services or all instances of a service)
  $service_check_interval           = getvar('::nagios_service_check_interval'),
  $service_check_period             = getvar('::nagios_service_check_period'),
  $service_contact_groups           = getvar('::nagios_service_contact_groups'),
  $service_first_notification_delay = getvar('::nagios_service_first_notification_delay'),
  $service_max_check_attempts       = getvar('::nagios_service_max_check_attempts'),
  $service_notification_period      = getvar('::nagios_service_notification_period'),
  $service_use                      = 'generic-service',
  # other
  $plugin_dir                       = $::nagios::params::plugin_dir,
  $selinux                          = true,
  $defaultchecks                    = true,
  # custom (nrpe) services/nrpe checks/nrpe plugins support
  $services                         = {},
  $nrpe_files                       = {},
  $nrpe_plugins                     = {},
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
  # The 'nrpe' name is either inside $nrpe_package or is $nrpe_package_alias
  package { $nrpe_package:
    ensure => 'installed',
    alias  => $nrpe_package_alias,
  }

  # Most plugins use nrpe, so we install it everywhere
  service { $nrpe_service:
    ensure    => 'running',
    enable    => true,
    hasstatus => true,
    subscribe => File[$nrpe_cfg_file],
  }
  file { $nrpe_cfg_file:
    owner   => 'root',
    group   => $nrpe_group,
    mode    => '0640',
    content => template('nagios/nrpe.cfg.erb'),
    require => Package['nrpe']
  }
  # Included in the package, but we need to enable purging
  file { $nrpe_cfg_dir:
    ensure  => 'directory',
    owner   => 'root',
    group   => $nrpe_group,
    mode    => '0750',
    purge   => true,
    recurse => true,
    require => Package['nrpe'],
  }
  # Create resource for the check_* parent resource
  file { $plugin_dir:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0775',
    require => Package['nrpe'],
  }

  # Where to store configuration for our custom nagios_* facts
  # These facts are mostly obsolete and pre-date hiera existence
  file { '/etc/nagios/facter':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
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

  # Enable all default checks by... default (can be disabled)
  # The check classes look up this scope's $service_* variables directly
  if $defaultchecks == true {
    # Always enabled ones (override $ensure to 'absent' to disable)
    class { '::nagios::check::conntrack': }
    class { '::nagios::check::cpu': }
    class { '::nagios::check::disk': }
    class { '::nagios::check::load': }
    class { '::nagios::check::ntp_time': }
    class { '::nagios::check::ping': }
    class { '::nagios::check::ping6': }
    class { '::nagios::check::ram': }
    class { '::nagios::check::swap': }
    # Conditional ones, once presence is detected using our custom facts
    if getvar('::nagios_couchbase') {
      class { '::nagios::check::couchbase': }
      class { '::nagios::check::couchbase_bucket': }
    }
    if getvar('::nagios_pci_hpsa') {         class { '::nagios::check::hpsa': } }
    if getvar('::nagios_httpd') {            class { '::nagios::check::httpd': } }
    if getvar('::nagios_pci_megaraid_sas') {
      class { '::nagios::check::megaraid_sas': }
      class { '::nagios::check::ssd': }
    }
    if /^nvme/ in $::disks {                 class { '::nagios::check::ssd': } }
    if getvar('::nagios_memcached') {        class { '::nagios::check::memcached': } }
    if getvar('::nagios_mongod') {           class { '::nagios::check::mongodb': } }
    if getvar('::nagios_mountpoints') {      class { '::nagios::check::mountpoints': } }
    if getvar('::nagios_moxi') {             class { '::nagios::check::moxi': } }
    if getvar('::nagios_httpd_nginx') {      class { '::nagios::check::nginx': } }
    if getvar('::nagios_pci_mptsas') {       class { '::nagios::check::mptsas': } }
    if getvar('::nagios_mysqld') {
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
    if getvar('::nagios_postgres') {  class { '::nagios::check::postgres': } }
    if getvar('::nagios_mdraid') {    class { '::nagios::check::mdraid': } }
    if getvar('::nagios_zookeeper') { class { '::nagios::check::zookeeper': } }
    if getvar('::nagios_rabbitmq') {  class { '::nagios::check::rabbitmq': } }
    if getvar('::nagios_redis') {
      class { '::nagios::check::redis': }
      class { '::nagios::check::redis_sentinel': }
    }
    if getvar('::nagios_ipa_server') {
      class { '::nagios::check::ipa': }
      class { '::nagios::check::ipa_replication': }
      class { '::nagios::check::krb5': }
    }
    if getvar('::virtual') == 'physical' {  class { '::nagios::check::cpu_temp': } }
    if getvar('::nagios_elasticsearch') {  class { '::nagios::check::elasticsearch': } }
    if getvar('::nagios_kafka') {
      class { '::nagios::check::kafka': }
      class { '::nagios::check::kafka_isr': }
    }
    if getvar('::nagios_clickhouse') {  class { '::nagios::check::clickhouse': } }
    if getvar('::nagios_chproxy') {  class { '::nagios::check::chproxy': } }
    if getvar('::nagios_haproxy') { class { '::nagios::check::haproxy_stats': } }
    if getvar('::nagios_consul') { class { '::nagios::check::consul': } }
  }

  # With selinux, some nrpe plugins require additional rules to work
  if $selinux and 'selinux' in $facts['os'] and  $facts['os']['selinux']['enabled'] == true {
    selinux::audit2allow { 'nrpe':
      source => "puppet:///modules/${module_name}/messages.nrpe",
    }
    selboolean { 'nagios_run_sudo':
      name       => 'nagios_run_sudo',
      persistent => true,
      value      => on,
    }
  }

  # Custom (nrpe) services/nrpe files/plugins support
  if $services {
    $_services = lookup({name => 'nagios::client::services', default_value => $services})
    create_resources('nagios::service', $_services)
  }

  if $nrpe_files {
    $_nrpe_files = lookup({name => 'nagios::client::nrpe_files', default_value => $nrpe_files})
    create_resources('nagios::client::nrpe_file', $_nrpe_files)
  }

  if $nrpe_plugins {
    $_nrpe_plugins = lookup({name => 'nagios::client::nrpe_plugins', default_value => $nrpe_plugins})
    create_resources('nagios::client::nrpe_plugin', $_nrpe_plugins)
  }

  # Optional nrpe plugins dependy, to be realized by the check
  # where is need it.
  $nagios_nrpe_plugin = [
    'nagioscheck.py',
  ]
  @nagios::client::nrpe_plugin { $nagios_nrpe_plugin:
    ensure  => 'present',
  }

}

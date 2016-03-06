# Nagios Server class
#
class nagios::server (
  # For the tag of the stored configuration to realize
  $nagios_server        = 'default',
  $nagios_service       = 'nagios',
  $nagios_package       = 'nagios',
  $cfg_path             = '/etc/nagios',
  $log_path             = '/var/log/nagios',
  $share_path           = '/usr/share/nagios/html',
  $url_path             = '/nagios',
  $usr_path             = '/usr/sbin',
  $cmd_path             = '/var/spool/nagios/cmd/nagios.cmd',
  $mailx_pkg            = 'bsd-mailx',
  $check_result_path    = '/var/log/nagios/spool/checkresults',
  $apache_httpd         = true,
  $apache_httpd_ssl     = true,
  $apache_httpd_modules = [
    'auth_basic',
    'authn_file',
    'authz_host',
    'authz_user',
    'env',
    'mime',
    'negotiation',
    'dir',
    'alias',
    'rewrite',
    'cgi',
  ],
  # The apache config snippet, more useful as a template when using a custom
  $apache_httpd_conf_content    = undef,
  $apache_httpd_conf_source     = undef,
  $apache_allowed_from          = [],   # Allow access in default template
  $apache_httpd_htpasswd_source = "puppet:///modules/${module_name}/apache_httpd/htpasswd",
  $php                          = true,
  $php_apc                      = true,
  $php_apc_module               = 'pecl-apc',
  # cgi.cfg
  $cgi_authorized_for_system_information        = 'nagiosadmin',
  $cgi_authorized_for_configuration_information = 'nagiosadmin',
  $cgi_authorized_for_system_commands           = 'nagiosadmin',
  $cgi_authorized_for_all_services              = 'nagiosadmin',
  $cgi_authorized_for_all_hosts                 = 'nagiosadmin',
  $cgi_authorized_for_all_service_commands      = 'nagiosadmin',
  $cgi_authorized_for_all_host_commands         = 'nagiosadmin',
  $cgi_default_statusmap_layout                 = '5',
  $cgi_result_limit                             = '100',
  # nagios.cfg
  $cfg_file = [
    # Where puppet managed types are
    "${cfg_path}/nagios_command.cfg",
    "${cfg_path}/nagios_contact.cfg",
    "${cfg_path}/nagios_contactgroup.cfg",
    "${cfg_path}/nagios_host.cfg",
    "${cfg_path}/nagios_hostdependency.cfg",
    "${cfg_path}/nagios_hostgroup.cfg",
    "${cfg_path}/nagios_service.cfg",
    "${cfg_path}/nagios_servicedependency.cfg",
    "${cfg_path}/nagios_servicegroup.cfg",
    "${cfg_path}/nagios_timeperiod.cfg",
  ],
  $cfg_dir                        = [],
  $process_performance_data       = '0',
  $host_perfdata_command          = false,
  $service_perfdata_command       = false,
  $service_perfdata_file          = false,
  $service_perfdata_file_template = '[SERVICEPERFDATA]\t$TIMET$\t$HOSTNAME$\t$SERVICEDESC$\t$SERVICEEXECUTIONTIME$\t$SERVICELATENCY$\t$SERVICEOUTPUT$\t$SERVICEPERFDATA$',
  $service_perfdata_file_mode     = 'a',
  $service_perfdata_file_processing_interval = '0',
  $service_perfdata_file_processing_command  = false,
  $enable_flap_detection = '1',
  $date_format = 'iso8601',
  $admin_email = 'root@localhost',
  $admin_pager = 'pagenagios@localhost',
  $cfg_append  = undef,
  $service_check_timeout = '60',
  $host_check_timeout    = '30',
  $event_handler_timeout = '30',
  $notification_timeout  = '30',
  $ocsp_timeout          = '5',
  $perfdata_timeout      = '5',
  # private/resource.cfg for $USERx$ macros (from 1 to 32)
  $user = {
    '1' => $::nagios::params::plugin_dir,
  },
  # Command and options for all nrpe-based checks
  $nrpe_command   = $::nagios::params::nrpe_command,
  $nrpe_options   = $::nagios::params::nrpe_options,
  # Contacts and Contact Groups
  $admins_members = 'nagiosadmin',
  # Others
  $notify_host_by_email_command_line    = '/usr/bin/printf "%b" "***** Nagios *****\n\nNotification Type: $NOTIFICATIONTYPE$\nHost: $HOSTNAME$\nState: $HOSTSTATE$\nAddress: $HOSTADDRESS$\nInfo: $HOSTOUTPUT$\n\nDate/Time: $LONGDATETIME$\n" | /bin/mail -s "** $NOTIFICATIONTYPE$ Host Alert: $HOSTNAME$ is $HOSTSTATE$ **" $CONTACTEMAIL$',
  $notify_service_by_email_command_line = '/usr/bin/printf "%b" "***** Nagios *****\n\nNotification Type: $NOTIFICATIONTYPE$\n\nService: $SERVICEDESC$\nHost: $HOSTALIAS$\nAddress: $HOSTADDRESS$\nState: $SERVICESTATE$\n\nDate/Time: $LONGDATETIME$\n\nAdditional Info:\n\n$SERVICEOUTPUT$" | /bin/mail -s "** $NOTIFICATIONTYPE$ Service Alert: $HOSTALIAS$/$SERVICEDESC$ is $SERVICESTATE$ **" $CONTACTEMAIL$',
  $timeperiod_workhours = '09:00-17:00',
  $plugin_dir           = $::nagios::params::plugin_dir,
  $plugin_nginx         = false,
  $plugin_xcache        = false,
  $selinux              = $::selinux,
  $packages             = [
    'nagios',
    'nagios-plugins-dhcp',
    'nagios-plugins-dns',
    'nagios-plugins-icmp',
    'nagios-plugins-ldap',
    'nagios-plugins-nrpe',
    'nagios-plugins-ping',
    'nagios-plugins-smtp',
    'nagios-plugins-snmp',
    'nagios-plugins-ssh',
    'nagios-plugins-tcp',
  ],
  # Original template entries
  $template_generic_contact = {},
  $template_generic_host    = {},
  $template_linux_server    = {},
  $template_windows_server  = {},
  $template_generic_printer = {},
  $template_generic_switch  = {},
  $template_generic_service = {},
  $template_local_service   = {},
  # Optional types
  $commands         = {},
  $contacts         = {},
  $contactgroups    = {},
  $hosts            = {},
  $hostdependencies = {},
  $hostgroups       = {},
  $services         = {},
  $servicegroups    = {},
  $timeperiods      = {},
) inherits ::nagios::params {

  # Full nrpe command to run, with default options
  $nrpe = "${nrpe_command} ${nrpe_options}"

  # Plugin packages required on the server side
  package { $packages:
    ensure => installed,
  }
  # Plugin packages required on both the client and server sides
  Package <| tag == 'nagios-plugins-http' |>

  # Custom plugin scripts required on the server
  if $plugin_nginx {
    file { "${plugin_dir}/check_nginx":
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => template('nagios/plugins/check_nginx'),
    }
  } else {
    file { "${plugin_dir}/check_nginx":
      ensure => absent,
    }
  }
  if $plugin_xcache {
    file { "${plugin_dir}/check_xcache":
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => template('nagios/plugins/check_xcache'),
    }
  } else {
    file { "${plugin_dir}/check_xcache":
      ensure => absent,
    }
  }

  # Other packages
  # For the default email notifications to work
  ensure_packages([$mailx_pkg])

  service { $nagios_service:
    ensure    => 'running',
    enable    => true,
    # "service nagios status" returns 0 when "nagios is not running" :-(
    hasstatus => false,
    # Don't get fooled by any process with "nagios" in its command line
    pattern   => '/usr/sbin/nagios',
    # Work around files created root:root mode 600 (known issue)
    restart   => "/bin/chgrp nagios ${cfg_path}/nagios_*.cfg && /bin/chmod 640 ${cfg_path}/nagios_*.cfg && `which service` $nagios_service reload",
    require   => Package[$nagios_package],
  }

  if $apache_httpd {
    class { '::apache_httpd':
      ssl       => $apache_httpd_ssl,
      modules   => $apache_httpd_modules,
      keepalive => 'On',
    }

    # Set a default content template if no content/source is specified
    if $apache_httpd_conf_source == undef {
      if $apache_httpd_conf_content == undef {
        $apache_httpd_conf_content_final = template("${module_name}/apache_httpd/httpd-nagios.conf.erb")
      } else {
        $apache_httpd_conf_content_final = $apache_httpd_conf_content
      }
    }
    file { '/etc/httpd/conf.d/nagios.conf':
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => $apache_httpd_conf_content_final,
      source  => $apache_httpd_conf_source,
      notify  => Service['httpd'],
      require => Package[$nagios_package],
    }
    if $apache_httpd_htpasswd_source != false {
      file { '/etc/nagios/.htpasswd':
        owner   => 'root',
        group   => 'apache',
        mode    => '0640',
        source  => $apache_httpd_htpasswd_source,
        require => Package[$nagios_package],
      }
    }
  }

  if $php {
    class { '::php::mod_php5': }
    php::ini { '/etc/php.ini': }
    if $php_apc { php::module { $php_apc_module: } }
  }

  # Configuration files
  if ($cfg_append != undef) {
    validate_hash($cfg_append)
  }
  file { "${cfg_path}/cgi.cfg":
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('nagios/cgi.cfg.erb'),
    # No need to reload the service, changes are applied immediately
    require => Package[$nagios_package],
  }
  file { "${cfg_path}/nagios.cfg":
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('nagios/nagios.cfg.erb'),
    notify  => Service[$nagios_service],
    require => Package[$nagios_package],
  }
  file { "${cfg_path}/private":
    ensure => directory,
  } -> 
  file { "${cfg_path}/private/resource.cfg":
    owner   => 'root',
    group   => 'nagios',
    mode    => '0640',
    content => template('nagios/resource.cfg.erb'),
    notify  => Service[$nagios_service],
    require => Package[$nagios_package],
  }

  # Realize all nagios related exported resources for this server
  # Automatically reload nagios for relevant configuration changes
  # Require the package for the parent directory to exist initially
  Nagios_command <<| tag == "nagios-${nagios_server}" |>> {
    notify  => Service[$nagios_service],
    require => Package[$nagios_package],
  }
  Nagios_contact <<| tag == "nagios-${nagios_server}" |>> {
    notify  => Service[$nagios_service],
    require => Package[$nagios_package],
  }
  Nagios_contactgroup <<| tag == "nagios-${nagios_server}" |>> {
    notify  => Service[$nagios_service],
    require => Package[$nagios_package],
  }
  Nagios_host <<| tag == "nagios-${nagios_server}" |>> {
    notify  => Service[$nagios_service],
    require => Package[$nagios_package],
  }
  Nagios_hostdependency <<| tag == "nagios-${nagios_server}" |>> {
    notify  => Service[$nagios_service],
    require => Package[$nagios_package],
  }
  Nagios_hostgroup <<| tag == "nagios-${nagios_server}" |>> {
    notify  => Service[$nagios_service],
    require => Package[$nagios_package],
  }
  Nagios_service <<| tag == "nagios-${nagios_server}" |>> {
    notify  => Service[$nagios_service],
    require => Package[$nagios_package],
  }
  Nagios_servicedependency <<| tag == "nagios-${nagios_server}" |>> {
    notify  => Service[$nagios_service],
    require => Package[$nagios_package],
  }
  Nagios_servicegroup <<| tag == "nagios-${nagios_server}" |>> {
    notify  => Service[$nagios_service],
    require => Package[$nagios_package],
  }
  Nagios_timeperiod <<| tag == "nagios-${nagios_server}" |>> {
    notify  => Service[$nagios_service],
    require => Package[$nagios_package],
  }

  # Auto reload and parent dir, but for non-exported resources
  # FIXME: This does not work from outside here, wrong scope.
  # We'll need to wrap around these types with our own
  # definitions like for "host"
  Nagios_command {
    notify  => Service[$nagios_service],
    require => Package[$nagios_package],
    target  => "${cfg_path}/nagios_command.cfg"
  }
  Nagios_contact {
    notify  => Service[$nagios_service],
    require => Package[$nagios_package],
    target  => "${cfg_path}/nagios_command.cfg"
  }
  Nagios_contactgroup {
    notify  => Service[$nagios_service],
    require => Package[$nagios_package],
    target  => "${cfg_path}/nagios_command.cfg"
  }
  Nagios_host {
    notify  => Service[$nagios_service],
    require => Package[$nagios_package],
    target  => "${cfg_path}/nagios_command.cfg"
  }
  Nagios_hostdependency {
    notify  => Service[$nagios_service],
    require => Package[$nagios_package],
    target  => "${cfg_path}/nagios_command.cfg"
  }
  Nagios_hostgroup {
    notify  => Service[$nagios_service],
    require => Package[$nagios_package],
    target  => "${cfg_path}/nagios_command.cfg"
  }
  Nagios_service {
    notify  => Service[$nagios_service],
    require => Package[$nagios_package],
    target  => "${cfg_path}/nagios_command.cfg"
  }
  Nagios_servicegroup {
    notify  => Service[$nagios_service],
    require => Package[$nagios_package],
    target  => "${cfg_path}/nagios_command.cfg"
  }
  Nagios_timeperiod {
    notify  => Service[$nagios_service],
    require => Package[$nagios_package],
    target  => "${cfg_path}/nagios_command.cfg"
  }

  # Works great, but only if the "target" is the default (known limitation)
  resources { [
    'nagios_command',
    'nagios_contact',
    'nagios_contactgroup',
    'nagios_host',
    'nagios_hostdependency',
    'nagios_hostgroup',
    'nagios_service',
    'nagios_servicegroup',
    'nagios_timeperiod',
  ]:
    purge => true,
    # For some reason, 'notify' is ignored when resources are purged :-(
    #notify => Service[$nagios_service],
  }

  # Work around a puppet bug where created files are 600 root:root
  file { [
    "${cfg_path}/nagios_command.cfg",
    "${cfg_path}/nagios_contact.cfg",
    "${cfg_path}/nagios_contactgroup.cfg",
    "${cfg_path}/nagios_host.cfg",
    "${cfg_path}/nagios_hostdependency.cfg",
    "${cfg_path}/nagios_hostgroup.cfg",
    "${cfg_path}/nagios_service.cfg",
    "${cfg_path}/nagios_servicedependency.cfg",
    "${cfg_path}/nagios_servicegroup.cfg",
    "${cfg_path}/nagios_timeperiod.cfg",
  ]:
    ensure => 'present',
    owner  => 'root',
    group  => 'nagios',
    mode   => '0640',
    before => Service[$nagios_service],
  }

  # Nagios commands
  # Taken from commands.cfg
  nagios_command { 'notify-host-by-email':
    command_line => $notify_host_by_email_command_line,
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'notify-service-by-email':
    command_line => $notify_service_by_email_command_line,
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check-host-alive':
    command_line => '$USER1$/check_ping -H $HOSTADDRESS$ -w 3000.0,80% -c 5000.0,100% -p 5',
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_ftp':
    command_line => '$USER1$/check_ftp -H $HOSTADDRESS$ $ARG1$',
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_hpjd':
    command_line => '$USER1$/check_hpjd -H $HOSTADDRESS$ $ARG1$',
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_snmp':
    command_line => '$USER1$/check_snmp -H $HOSTADDRESS$ $ARG1$',
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_http':
    command_line => '$USER1$/check_http -I $HOSTADDRESS$ $ARG1$',
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_ssh':
    command_line => '$USER1$/check_ssh $ARG1$ $HOSTADDRESS$',
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_dhcp':
    command_line => '$USER1$/check_dhcp $ARG1$',
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_ping':
    command_line => '$USER1$/check_ping -H $HOSTADDRESS$ $ARG1$',
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_ping6':
    command_line => '$USER1$/check_ping -6 $ARG1$',
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_pop':
    command_line => '$USER1$/check_pop -H $HOSTADDRESS$ $ARG1$',
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_imap':
    command_line => '$USER1$/check_imap -H $HOSTADDRESS$ $ARG1$',
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_smtp':
    command_line => '$USER1$/check_smtp -H $HOSTADDRESS$ $ARG1$',
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_tcp':
    command_line => '$USER1$/check_tcp -H $HOSTADDRESS$ -p $ARG1$ $ARG2$',
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_udp':
    command_line => '$USER1$/check_udp -H $HOSTADDRESS$ -p $ARG1$ $ARG2$',
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nt':
    command_line => '$USER1$/check_nt -H $HOSTADDRESS$ -p 12489 -v $ARG1$ $ARG2$',
    target       => "${cfg_path}/nagios_command.cfg"
  }
  # Custom commands
  nagios_command { 'check_ping_addr':
    command_line => '$USER1$/check_ping -H $ARG1$ -w $ARG2$ -c $ARG3$ -p 5',
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_dns':
    command_line => '$USER1$/check_dns -H $HOSTADDRESS$ $ARG1$',
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_dns_addr':
    command_line => '$USER1$/check_dns -H $ARG1$ $ARG2$',
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_http_url':
    command_line => '$USER1$/check_http -H $ARG1$ -p $ARG2$ $ARG3$',
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_proxy':
    command_line => '$USER1$/check_tcp -H $HOSTADDRESS$ -p $ARG1$',
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nginx':
    command_line => '$USER1$/check_nginx $ARG1$',
    target       => "${cfg_path}/nagios_command.cfg"
  }
  # Custom NRPE-based commands
  nagios_command { 'check_nrpe_users':
    command_line => "${nrpe} -c check_users",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_load':
    command_line => "${nrpe} -c check_load",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_zombie_procs':
    command_line => "${nrpe} -c check_zombie_procs",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_total_procs':
    command_line => "${nrpe} -c check_total_procs",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_swap':
    command_line => "${nrpe} -c check_swap",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_disk':
    command_line => "${nrpe} -c check_disk",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_procs':
    command_line => "${nrpe} -c check_procs",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_ntp_time':
    command_line => "${nrpe} -u -c check_ntp_time",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  # Custom NRPE-based commands using custom plugins
  nagios_command { 'check_nrpe_ram':
    command_line => "${nrpe} -c check_ram",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_cpu':
    command_line => "${nrpe} -c check_cpu",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_couchbase':
    command_line => "${nrpe} -c check_couchbase",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_moxi':
    command_line => "${nrpe} -c check_moxi",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_memcached':
    command_line => "${nrpe} -c check_memcached",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_conntrack':
    command_line => "${nrpe} -c check_conntrack",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  # Custom NRPE-based commands using custom plugins, conditionally enabled
  nagios_command { 'check_nrpe_megaraid_sas':
    command_line => "${nrpe} -c check_megaraid_sas",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_mptsas':
    command_line => "${nrpe} -c check_mptsas",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_mysql_health_connection_time':
    command_line => "${nrpe} -c check_mysql_health_connection_time",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_mysql_health_uptime':
    command_line => "${nrpe} -c check_mysql_health_uptime",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_mysql_health_threads_connected':
    command_line => "${nrpe} -c check_mysql_health_threads_connected",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_mysql_health_threadcache_hitrate':
    command_line => "${nrpe} -c check_mysql_health_threadcache_hitrate",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_mysql_health_querycache_hitrate':
    command_line => "${nrpe} -c check_mysql_health_querycache_hitrate",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_mysql_health_querycache_lowmem_prunes':
    command_line => "${nrpe} -c check_mysql_health_querycache_lowmem_prunes",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_mysql_health_keycache_hitrate':
    command_line => "${nrpe} -c check_mysql_health_keycache_hitrate",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_mysql_health_bufferpool_hitrate':
    command_line => "${nrpe} -c check_mysql_health_bufferpool_hitrate",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_mysql_health_bufferpool_wait_free':
    command_line => "${nrpe} -c check_mysql_health_bufferpool_wait_free",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_mysql_health_log_waits':
    command_line => "${nrpe} -c check_mysql_health_log_waits",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_mysql_health_tablecache_hitrate':
    command_line => "${nrpe} -c check_mysql_health_tablecache_hitrate",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_mysql_health_table_lock_contention':
    command_line => "${nrpe} -c check_mysql_health_table_lock_contention",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_mysql_health_index_usage':
    command_line => "${nrpe} -c check_mysql_health_index_usage",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_mysql_health_tmp_disk_tables':
    command_line => "${nrpe} -c check_mysql_health_tmp_disk_tables",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_mysql_health_slow_queries':
    command_line => "${nrpe} -c check_mysql_health_slow_queries",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_mysql_health_slave_lag':
    command_line => "${nrpe} -c check_mysql_health_slave_lag",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_mysql_health_slave_io_running':
    command_line => "${nrpe} -c check_mysql_health_slave_io_running",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_mysql_health_slave_sql_running':
    command_line => "${nrpe} -c check_mysql_health_slave_sql_running",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_mysql_health_open_files':
    command_line => "${nrpe} -c check_mysql_health_open_files",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_archive_ready':
    command_line => "${nrpe} -c check_postgres_archive_ready",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_autovac_freeze':
    command_line => "${nrpe} -c check_postgres_autovac_freeze",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_backends':
    command_line => "${nrpe} -c check_postgres_backends",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_bloat':
    command_line => "${nrpe} -c check_postgres_bloat",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_checkpoint':
    command_line => "${nrpe} -c check_postgres_checkpoint",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_cluster_id':
    command_line => "${nrpe} -c check_postgres_cluster_id",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_commitratio':
    command_line => "${nrpe} -c check_postgres_commitratio",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_connection':
    command_line => "${nrpe} -c check_postgres_connection",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_database_size':
    command_line => "${nrpe} -c check_postgres_database_size",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_disabled_triggers':
    command_line => "${nrpe} -c check_postgres_disabled_triggers",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_disk_space':
    command_line => "${nrpe} -c check_postgres_disk_space",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_fsm_pages':
    command_line => "${nrpe} -c check_postgres_fsm_pages",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_fsm_relations':
    command_line => "${nrpe} -c check_postgres_fsm_relations",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_hitratio':
    command_line => "${nrpe} -c check_postgres_hitratio",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_hot_standby_delay':
    command_line => "${nrpe} -c check_postgres_hot_standby_delay",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_last_analyze':
    command_line => "${nrpe} -c check_postgres_last_analyze",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_last_vacuum':
    command_line => "${nrpe} -c check_postgres_last_vacuum",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_last_autoanalyze':
    command_line => "${nrpe} -c check_postgres_last_autoanalyze",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_last_autovacuum':
    command_line => "${nrpe} -c check_postgres_last_autovacuum",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_listener':
    command_line => "${nrpe} -c check_postgres_listener",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_locks':
    command_line => "${nrpe} -c check_postgres_locks",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_logfile':
    command_line => "${nrpe} -c check_postgres_logfile",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_new_version_bc':
    command_line => "${nrpe} -c check_postgres_new_version_bc",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_new_version_box':
    command_line => "${nrpe} -c check_postgres_new_version_box",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_new_version_cp':
    command_line => "${nrpe} -c check_postgres_new_version_cp",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_new_version_pg':
    command_line => "${nrpe} -c check_postgres_new_version_pg",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_new_version_tnm':
    command_line => "${nrpe} -c check_postgres_new_version_tnm",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_pgb_pool_cl_active':
    command_line => "${nrpe} -c check_postgres_pgb_pool_cl_active",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_pgb_pool_cl_waiting':
    command_line => "${nrpe} -c check_postgres_pgb_pool_cl_waiting",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_pgb_pool_sv_active':
    command_line => "${nrpe} -c check_postgres_pgb_pool_sv_active",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_pgb_pool_sv_idle':
    command_line => "${nrpe} -c check_postgres_pgb_pool_sv_idle",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_pgb_pool_sv_used':
    command_line => "${nrpe} -c check_postgres_pgb_pool_sv_used",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_pgb_pool_sv_tested':
    command_line => "${nrpe} -c check_postgres_pgb_pool_sv_tested",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_pgb_pool_sv_login':
    command_line => "${nrpe} -c check_postgres_pgb_pool_sv_login",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_pgb_pool_sv_maxwait':
    command_line => "${nrpe} -c check_postgres_pgb_pool_sv_maxwait",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_pgbouncer_backends':
    command_line => "${nrpe} -c check_postgres_pgbouncer_backends",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_pgbouncer_checksum':
    command_line => "${nrpe} -c check_postgres_pgbouncer_checksum",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_pgagent_jobs':
    command_line => "${nrpe} -c check_postgres_pgagent_jobs",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_prepared_txns':
    command_line => "${nrpe} -c check_postgres_prepared_txns",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_query_time':
    command_line => "${nrpe} -c check_postgres_query_time",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_same_schema':
    command_line => "${nrpe} -c check_postgres_same_schema",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_sequence':
    command_line => "${nrpe} -c check_postgres_sequence",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_settings_checksum':
    command_line => "${nrpe} -c check_postgres_settings_checksum",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_slony_status':
    command_line => "${nrpe} -c check_postgres_slony_status",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_txn_idle':
    command_line => "${nrpe} -c check_postgres_txn_idle",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_txn_time':
    command_line => "${nrpe} -c check_postgres_txn_time",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_txn_wraparound':
    command_line => "${nrpe} -c check_postgres_txn_wraparound",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_version':
    command_line => "${nrpe} -c check_postgres_version",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command { 'check_nrpe_postgres_wal_files':
    command_line => "${nrpe} -c check_postgres_wal_files",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command {'check_nrpe_mongodb_asserts':
    command_line => "${nrpe} -c check_mongodb_asserts",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command {'check_nrpe_mongodb_chunks_balance':
    command_line => "${nrpe} -c check_mongodb_chunks_balance",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command {'check_nrpe_mongodb_collection_indexes':
    command_line => "${nrpe} -c check_mongodb_collection_indexes",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command {'check_nrpe_mongodb_collections':
    command_line => "${nrpe} -c check_mongodb_collections",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command {'check_nrpe_mongodb_collection_size':
    command_line => "${nrpe} -c check_mongodb_collection_size",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command {'check_nrpe_mongodb_collection_state':
    command_line => "${nrpe} -c check_mongodb_collection_state",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command {'check_nrpe_mongodb_collection_storageSize':
    command_line => "${nrpe} -c check_mongodb_collection_storageSize",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command {'check_nrpe_mongodb_connect':
    command_line => "${nrpe} -c check_mongodb_connect",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command {'check_nrpe_mongodb_connections':
    command_line => "${nrpe} -c check_mongodb_connections",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command {'check_nrpe_mongodb_connect_primary':
    command_line => "${nrpe} -c check_mongodb_connect_primary",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command {'check_nrpe_mongodb_current_lock':
    command_line => "${nrpe} -c check_mongodb_current_lock",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command {'check_nrpe_mongodb_database_indexes':
    command_line => "${nrpe} -c check_mongodb_database_indexes",

  }
  nagios_command {'check_nrpe_mongodb_databases':
    command_line => "${nrpe} -c check_mongodb_databases",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command {'check_nrpe_mongodb_database_size':
    command_line => "${nrpe} -c check_mongodb_database_size",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command {'check_nrpe_mongodb_flushing':
    command_line => "${nrpe} -c check_mongodb_flushing",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command {'check_nrpe_mongodb_index_miss_ratio':
    command_line => "${nrpe} -c check_mongodb_index_miss_ratio",
    target       => "${cfg_path}/nagios_command.cfg" 
  }
  nagios_command {'check_nrpe_mongodb_journal_commits_in_wl':
    command_line => "${nrpe} -c check_mongodb_journal_commits_in_wl",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command {'check_nrpe_mongodb_journaled':
    command_line => "${nrpe} -c check_mongodb_journaled",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command {'check_nrpe_mongodb_last_flush_time':
    command_line => "${nrpe} -c check_mongodb_last_flush_time",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command {'check_nrpe_mongodb_lock':
    command_line => "${nrpe} -c check_mongodb_lock",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command {'check_nrpe_mongodb_memory':
    command_line => "${nrpe} -c check_mongodb_memory",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command {'check_nrpe_mongodb_memory_mapped':
    command_line => "${nrpe} -c check_mongodb_memory_mapped",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command {'check_nrpe_mongodb_opcounters':
    command_line => "${nrpe} -c check_mongodb_opcounters",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command {'check_nrpe_mongodb_oplog':
    command_line => "${nrpe} -c check_mongodb_oplog",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command {'check_nrpe_mongodb_page_faults':
    command_line => "${nrpe} -c check_mongodb_page_faults",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command {'check_nrpe_mongodb_queries_per_second':
    command_line => "${nrpe} -c check_mongodb_queries_per_second",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command {'check_nrpe_mongodb_queues':
    command_line => "${nrpe} -c check_mongodb_queues",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command {'check_nrpe_mongodb_replica_primary':
    command_line => "${nrpe} -c check_mongodb_replica_primary",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command {'check_nrpe_mongodb_replication_lag':
    command_line => "${nrpe} -c check_mongodb_replication_lag",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command {'check_nrpe_mongodb_replication_lag_percent':
    command_line => "${nrpe} -c check_mongodb_replication_lag_percent",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command {'check_nrpe_mongodb_replset_quorum':
    command_line => "${nrpe} -c check_mongodb_replset_quorum",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command {'check_nrpe_mongodb_replset_state':
    command_line => "${nrpe} -c check_mongodb_replset_state",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command {'check_nrpe_mongodb_row_count':
    command_line => "${nrpe} -c check_mongodb_row_count",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command {'check_nrpe_mongodb_write_data_files':
    command_line => "${nrpe} -c check_mongodb_write_data_files",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command {'check_nrpe_hpsa':
    command_line => "${nrpe} -c check_hpsa",
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_command {'check_nrpe_mountpoints':
    command_line => "${nrpe} -c check_mountpoints",
    target       => "${cfg_path}/nagios_command.cfg"
  }

  # Nagios contacts and contactgroups
  # Taken from contacts.cfg
  nagios_contact { 'nagiosadmin':
    use   => 'generic-contact',
    alias => 'Nagios Admin',
    email => $admin_email,
  }
  nagios_contactgroup { 'admins':
    alias   => 'Nagios Administrators',
    members => $admins_members,
    target       => "${cfg_path}/nagios_command.cfg"
  }

  # Nagios timeperiods
  # Taken from timeperiods.cfg
  nagios_timeperiod { '24x7':
    alias     => '24 Hours A Day, 7 Days A Week',
    monday    => '00:00-24:00',
    tuesday   => '00:00-24:00',
    wednesday => '00:00-24:00',
    thursday  => '00:00-24:00',
    friday    => '00:00-24:00',
    saturday  => '00:00-24:00',
    sunday    => '00:00-24:00',
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_timeperiod { 'workhours':
    alias     => 'Normal Work Hours',
    monday    => $timeperiod_workhours,
    tuesday   => $timeperiod_workhours,
    wednesday => $timeperiod_workhours,
    thursday  => $timeperiod_workhours,
    friday    => $timeperiod_workhours,
    target       => "${cfg_path}/nagios_command.cfg"
  }
  nagios_timeperiod { 'none':
    alias => 'No Time Is A Good Time',
    target       => "${cfg_path}/nagios_command.cfg"
  }

  # Nagios templates for various objects
  # Taken as-is from objects/templates.cfg
  $template_generic_contact_defaults = {
    'service_notification_period'   => '24x7',
    'host_notification_period'      => '24x7',
    'service_notification_options'  => 'u,c,r,f,s',
    'host_notification_options'     => 'd,u,r,f,s',
    'service_notification_commands' => 'notify-service-by-email',
    'host_notification_commands'    => 'notify-host-by-email',
    'register'                      => '0',
  }
  create_resources (nagios_contact, { 'generic-contact' => $template_generic_contact }, $template_generic_contact_defaults)
  $template_generic_host_defaults = {
    'notifications_enabled'        => '1',
    'event_handler_enabled'        => '1',
    'flap_detection_enabled'       => '1',
    'failure_prediction_enabled'   => '1',
    'process_perf_data'            => '1',
    'retain_status_information'    => '1',
    'retain_nonstatus_information' => '1',
    'notification_period'          => '24x7',
    'register'                     => '0',
  }
  create_resources (nagios_host, { 'generic-host' => $template_generic_host }, $template_generic_host_defaults)
  $template_linux_server_defaults = {
    'use'                   => 'generic-host',
    'check_period'          => '24x7',
    'check_interval'        => '5',
    'retry_interval'        => '1',
    'max_check_attempts'    => '10',
    'check_command'         => 'check-host-alive',
    'notification_period'   => '24x7',
    'notification_interval' => '120',
    'notification_options'  => 'd,u,r',
    'contact_groups'        => 'admins',
    'register'              => '0',
  }
  create_resources (nagios_host, { 'linux-server' => $template_linux_server }, $template_linux_server_defaults)
  $template_windows_server_defaults = {
    'use'                   => 'generic-host',
    'check_period'          => '24x7',
    'check_interval'        => '5',
    'retry_interval'        => '1',
    'max_check_attempts'    => '10',
    'check_command'         => 'check-host-alive',
    'notification_period'   => '24x7',
    'notification_interval' => '30',
    'notification_options'  => 'd,r',
    'contact_groups'        => 'admins',
    'hostgroups'            => 'windows-servers',
    'register'              => '0',
  }
  create_resources (nagios_host, { 'windows-server' => $template_windows_server }, $template_windows_server_defaults)
  $template_generic_printer_defaults = {
    'use'                   => 'generic-host',
    'check_period'          => '24x7',
    'check_interval'        => '5',
    'retry_interval'        => '1',
    'max_check_attempts'    => '10',
    'check_command'         => 'check-host-alive',
    'notification_period'   => 'workhours',
    'notification_interval' => '30',
    'notification_options'  => 'd,r',
    'contact_groups'        => 'admins',
    'register'              => '0',
  }
  create_resources (nagios_host, { 'generic-printer' => $template_generic_printer }, $template_generic_printer_defaults)
  $template_generic_switch_defaults = {
    'use'                   => 'generic-host',
    'check_period'          => '24x7',
    'check_interval'        => '5',
    'retry_interval'        => '1',
    'max_check_attempts'    => '10',
    'check_command'         => 'check-host-alive',
    'notification_period'   => '24x7',
    'notification_interval' => '30',
    'notification_options'  => 'd,r',
    'contact_groups'        => 'admins',
    'register'              => '0',
  }
  create_resources (nagios_host, { 'generic-switch' => $template_generic_switch }, $template_generic_switch_defaults)
  $template_generic_service_defaults = {
    'active_checks_enabled'        => '1',
    'passive_checks_enabled'       => '1',
    'parallelize_check'            => '1',
    'obsess_over_service'          => '1',
    'check_freshness'              => '0',
    'notifications_enabled'        => '1',
    'event_handler_enabled'        => '1',
    'flap_detection_enabled'       => '1',
    'failure_prediction_enabled'   => '1',
    'process_perf_data'            => '1',
    'retain_status_information'    => '1',
    'retain_nonstatus_information' => '1',
    'is_volatile'                  => '0',
    'check_period'                 => '24x7',
    'max_check_attempts'           => '3',
    'normal_check_interval'        => '10',
    'retry_check_interval'         => '2',
    'contact_groups'               => 'admins',
    'notification_options'         => 'w,u,c,r',
    'notification_interval'        => '60',
    'notification_period'          => '24x7',
    'register'                     => '0',
  }
  create_resources (nagios_service, { 'generic-service' => $template_generic_service }, $template_generic_service_defaults)
  $template_local_service_defaults = {
    'use'                   => 'generic-service',
    'max_check_attempts'    => '4',
    'normal_check_interval' => '5',
    'retry_check_interval'  => '1',
    'register'              => '0',
  }
  create_resources (nagios_service, { 'local-service' => $template_local_service }, $template_local_service_defaults)

  # Create all resources for nagios types
  create_resources (nagios_command, $commands)
  create_resources (nagios_contact, $contacts)
  create_resources (nagios_contactgroup, $contactgroups)
  create_resources (nagios_host, $hosts)
  create_resources (nagios_hostdependency, $hostdependencies)
  create_resources (nagios_hostgroup, $hostgroups)
  create_resources (nagios_service, $services)
  create_resources (nagios_servicegroup, $servicegroups)
  create_resources (nagios_timeperiod, $timeperiods)

  # Additional useful resources
  nagios_servicegroup { 'mysql_health':
    alias => 'MySQL Health service checks',
  }
  nagios_servicegroup { 'postgres':
    alias => 'PostgreSQL service checks',
  }
  nagios_servicegroup { 'mongodb':
    alias => 'MongoDB service checks',
  }

  # With selinux, adjustements are needed for nagiosgraph
  # lint:ignore:quoted_booleans
  if ( ( $selinux == true and $::selinux_enforced == true ) or
  ( $selinux == 'true' and $::selinux_enforced == 'true' ) ) {
    selinux::audit2allow { 'nagios':
      source => "puppet:///modules/${module_name}/messages.nagios",
    }
  }
  # lint:endignore

}

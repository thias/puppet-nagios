class nagios::server (
  # For the tag of the stored configuration to realize
  $nagios_server        = 'default',
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
  $php     = true,
  $php_apc = true,
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
    '/etc/nagios/nagios_command.cfg',
    '/etc/nagios/nagios_contact.cfg',
    '/etc/nagios/nagios_contactgroup.cfg',
    '/etc/nagios/nagios_host.cfg',
    '/etc/nagios/nagios_hostdependency.cfg',
    '/etc/nagios/nagios_hostgroup.cfg',
    '/etc/nagios/nagios_service.cfg',
    '/etc/nagios/nagios_servicedependency.cfg',
    '/etc/nagios/nagios_servicegroup.cfg',
    '/etc/nagios/nagios_timeperiod.cfg',
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
  $date_format = 'iso8601',
  $admin_email = 'root@localhost',
  $admin_pager = 'pagenagios@localhost',
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
  $hostgroups       = {},
  $servicegroups    = {},
) inherits ::nagios::params {

  # Full nrpe command to run, with default options
  $nrpe = "${nrpe_command} ${nrpe_options}"

  # Plugin packages required on the server side
  package { [
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
  ]:
    ensure => installed,
  }
  # Plugin packages required on both the client and server sides
  Package <| tag == 'nagios-plugins-http' |>

  # Custom plugin scripts required on the server
  if $plugin_nginx {
    file { "${plugin_dir}/check_nginx":
      ensure  => $ensure,
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
      ensure  => $ensure,
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
  package { [
    'mailx', # For the default email notifications to work
  ]:
    ensure => installed,
  }

  service { 'nagios':
    ensure    => running,
    enable    => true,
    # "service nagios status" returns 0 when "nagios is not running" :-(
    hasstatus => false,
    # Don't get fooled by any process with "nagios" in its command line
    pattern   => '/usr/sbin/nagios',
    # Work around files created root:root mode 600 (known issue)
    restart   => '/bin/chgrp nagios /etc/nagios/nagios_*.cfg && /bin/chmod 640 /etc/nagios/nagios_*.cfg && /sbin/service nagios reload',
    require   => Package['nagios'],
  }

  # Set a default content template if no content/source is specified
  if $apache_httpd_conf_source == '' {
    if $apache_httpd_conf_content == '' {
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
    require => Package['nagios'],
  }
  if $apache_httpd_htpasswd_source != false {
    file { '/etc/nagios/.htpasswd':
      owner   => 'root',
      group   => 'apache',
      mode    => '0640',
      source  => $apache_httpd_htpasswd_source,
      require => Package['nagios'],
    }
  }

  if $apache_httpd {
    apache_httpd { 'prefork':
      ssl       => $apache_httpd_ssl,
      modules   => $apache_httpd_modules,
      keepalive => 'On',
    }
  }

  if $php {
    class { '::php::mod_php5': }
    php::ini { '/etc/php.ini': }
    if $php_apc { php::module { 'pecl-apc': } }
  }

  # Configuration files
  file { '/etc/nagios/cgi.cfg':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('nagios/cgi.cfg.erb'),
    # No need to reload the service, changes are applied immediately
    require => Package['nagios'],
  }
  file { '/etc/nagios/nagios.cfg':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('nagios/nagios.cfg.erb'),
    notify  => Service['nagios'],
    require => Package['nagios'],
  }
  file { '/etc/nagios/private/resource.cfg':
    owner   => 'root',
    group   => 'nagios',
    mode    => '0640',
    content => template('nagios/resource.cfg.erb'),
    notify  => Service['nagios'],
    require => Package['nagios'],
  }

  # Realize all nagios related exported resources for this server
  # Automatically reload nagios for relevant configuration changes
  # Require the package for the parent directory to exist initially
  Nagios_command <<| tag == "nagios-${nagios_server}" |>> {
    notify  => Service['nagios'],
    require => Package['nagios'],
  }
  Nagios_contact <<| tag == "nagios-${nagios_server}" |>> {
    notify  => Service['nagios'],
    require => Package['nagios'],
  }
  Nagios_contactgroup <<| tag == "nagios-${nagios_server}" |>> {
    notify  => Service['nagios'],
    require => Package['nagios'],
  }
  Nagios_host <<| tag == "nagios-${nagios_server}" |>> {
    notify  => Service['nagios'],
    require => Package['nagios'],
  }
  Nagios_hostdependency <<| tag == "nagios-${nagios_server}" |>> {
    notify  => Service['nagios'],
    require => Package['nagios'],
  }
  Nagios_hostgroup <<| tag == "nagios-${nagios_server}" |>> {
    notify  => Service['nagios'],
    require => Package['nagios'],
  }
  Nagios_service <<| tag == "nagios-${nagios_server}" |>> {
    notify  => Service['nagios'],
    require => Package['nagios'],
  }
  Nagios_servicedependency <<| tag == "nagios-${nagios_server}" |>> {
    notify  => Service['nagios'],
    require => Package['nagios'],
  }
  Nagios_servicegroup <<| tag == "nagios-${nagios_server}" |>> {
    notify  => Service['nagios'],
    require => Package['nagios'],
  }
  Nagios_timeperiod <<| tag == "nagios-${nagios_server}" |>> {
    notify  => Service['nagios'],
    require => Package['nagios'],
  }

  # Auto reload and parent dir, but for non-exported resources
  # FIXME: This does not work from outside here, wrong scope.
  # We'll need to wrap around these types with our own
  # definitions like for "host"
  Nagios_command {
    notify  => Service['nagios'],
    require => Package['nagios'],
  }
  Nagios_contact {
    notify  => Service['nagios'],
    require => Package['nagios'],
  }
  Nagios_contactgroup {
    notify  => Service['nagios'],
    require => Package['nagios'],
  }
  Nagios_host {
    notify  => Service['nagios'],
    require => Package['nagios'],
  }
  Nagios_hostdependency {
    notify  => Service['nagios'],
    require => Package['nagios'],
  }
  Nagios_hostgroup {
    notify  => Service['nagios'],
    require => Package['nagios'],
  }
  Nagios_service {
    notify  => Service['nagios'],
    require => Package['nagios'],
  }
  Nagios_servicegroup {
    notify  => Service['nagios'],
    require => Package['nagios'],
  }
  Nagios_timeperiod {
    notify  => Service['nagios'],
    require => Package['nagios'],
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
  }

  # Work around a puppet bug where created files are 600 root:root
  file { [
    '/etc/nagios/nagios_command.cfg',
    '/etc/nagios/nagios_contact.cfg',
    '/etc/nagios/nagios_contactgroup.cfg',
    '/etc/nagios/nagios_host.cfg',
    '/etc/nagios/nagios_hostdependency.cfg',
    '/etc/nagios/nagios_hostgroup.cfg',
    '/etc/nagios/nagios_service.cfg',
    '/etc/nagios/nagios_servicedependency.cfg',
    '/etc/nagios/nagios_servicegroup.cfg',
    '/etc/nagios/nagios_timeperiod.cfg',
  ]:
    ensure => present,
    owner  => 'root',
    group  => 'nagios',
    mode   => '0640',
    before => Service['nagios'],
  }

  # Nagios commands
  # Taken from commands.cfg
  nagios_command { 'notify-host-by-email':
    command_line => $notify_host_by_email_command_line,
  }
  nagios_command { 'notify-service-by-email':
    command_line => $notify_service_by_email_command_line,
  }
  nagios_command { 'check-host-alive':
    command_line => '$USER1$/check_ping -H $HOSTADDRESS$ -w 3000.0,80% -c 5000.0,100% -p 5',
  }
  nagios_command { 'check_ftp':
    command_line => '$USER1$/check_ftp -H $HOSTADDRESS$ $ARG1$',
  }
  nagios_command { 'check_hpjd':
    command_line => '$USER1$/check_hpjd -H $HOSTADDRESS$ $ARG1$',
  }
  nagios_command { 'check_snmp':
    command_line => '$USER1$/check_snmp -H $HOSTADDRESS$ $ARG1$',
  }
  nagios_command { 'check_http':
    command_line => '$USER1$/check_http -I $HOSTADDRESS$ $ARG1$',
  }
  nagios_command { 'check_ssh':
    command_line => '$USER1$/check_ssh $ARG1$ $HOSTADDRESS$',
  }
  nagios_command { 'check_dhcp':
    command_line => '$USER1$/check_dhcp $ARG1$',
  }
  nagios_command { 'check_ping':
    command_line => '$USER1$/check_ping -H $HOSTADDRESS$ $ARG1$',
  }
  nagios_command { 'check_pop':
    command_line => '$USER1$/check_pop -H $HOSTADDRESS$ $ARG1$',
  }
  nagios_command { 'check_imap':
    command_line => '$USER1$/check_imap -H $HOSTADDRESS$ $ARG1$',
  }
  nagios_command { 'check_smtp':
    command_line => '$USER1$/check_smtp -H $HOSTADDRESS$ $ARG1$',
  }
  nagios_command { 'check_tcp':
    command_line => '$USER1$/check_tcp -H $HOSTADDRESS$ -p $ARG1$ $ARG2$',
  }
  nagios_command { 'check_udp':
    command_line => '$USER1$/check_udp -H $HOSTADDRESS$ -p $ARG1$ $ARG2$',
  }
  nagios_command { 'check_nt':
    command_line => '$USER1$/check_nt -H $HOSTADDRESS$ -p 12489 -v $ARG1$ $ARG2$',
  }
  # Custom commands
  nagios_command { 'check_ping_addr':
    command_line => '$USER1$/check_ping -H $ARG1$ -w $ARG2$ -c $ARG3$ -p 5',
  }
  nagios_command { 'check_dns':
    command_line => '$USER1$/check_dns -H $HOSTADDRESS$ $ARG1$',
  }
  nagios_command { 'check_dns_addr':
    command_line => '$USER1$/check_dns -H $ARG1$ $ARG2$',
  }
  nagios_command { 'check_http_url':
    command_line => '$USER1$/check_http -H $ARG1$ -p $ARG2$ $ARG3$',
  }
  nagios_command { 'check_proxy':
    command_line => '$USER1$/check_tcp -H $HOSTADDRESS$ -p $ARG1$',
  }
  nagios_command { 'check_nginx':
    command_line => '$USER1$/check_nginx $ARG1$',
  }
  # Custom NRPE-based commands
  nagios_command { 'check_nrpe_users':
    command_line => "${nrpe} -c check_users",
  }
  nagios_command { 'check_nrpe_load':
    command_line => "${nrpe} -c check_load",
  }
  nagios_command { 'check_nrpe_zombie_procs':
    command_line => "${nrpe} -c check_zombie_procs",
  }
  nagios_command { 'check_nrpe_total_procs':
    command_line => "${nrpe} -c check_total_procs",
  }
  nagios_command { 'check_nrpe_swap':
    command_line => "${nrpe} -c check_swap",
  }
  nagios_command { 'check_nrpe_disk':
    command_line => "${nrpe} -c check_disk",
  }
  nagios_command { 'check_nrpe_procs':
    command_line => "${nrpe} -c check_procs",
  }
  nagios_command { 'check_nrpe_ntp_time':
    command_line => "${nrpe} -c check_ntp_time",
  }
  # Custom NRPE-based commands using custom plugins
  nagios_command { 'check_nrpe_ram':
    command_line => "${nrpe} -c check_ram",
  }
  nagios_command { 'check_nrpe_cpu':
    command_line => "${nrpe} -c check_cpu",
  }
  nagios_command { 'check_nrpe_membase':
    command_line => "${nrpe} -c check_membase",
  }
  nagios_command { 'check_nrpe_couchbase':
    command_line => "${nrpe} -c check_couchbase",
  }
  nagios_command { 'check_nrpe_moxi':
    command_line => "${nrpe} -c check_moxi",
  }
  nagios_command { 'check_nrpe_memcached':
    command_line => "${nrpe} -c check_memcached",
  }
  nagios_command { 'check_nrpe_conntrack':
    command_line => "${nrpe} -c check_conntrack",
  }
  # Custom NRPE-based commands using custom plugins, conditionally enabled
  nagios_command { 'check_nrpe_megaraid_sas':
    command_line => "${nrpe} -c check_megaraid_sas",
  }
  nagios_command { 'check_nrpe_mptsas':
    command_line => "${nrpe} -c check_mptsas",
  }
  nagios_command { 'check_nrpe_mysql_health_connection_time':
    command_line => "${nrpe} -c check_mysql_health_connection_time",
  }
  nagios_command { 'check_nrpe_mysql_health_uptime':
    command_line => "${nrpe} -c check_mysql_health_uptime",
  }
  nagios_command { 'check_nrpe_mysql_health_threads_connected':
    command_line => "${nrpe} -c check_mysql_health_threads_connected",
  }
  nagios_command { 'check_nrpe_mysql_health_threadcache_hitrate':
    command_line => "${nrpe} -c check_mysql_health_threadcache_hitrate",
  }
  nagios_command { 'check_nrpe_mysql_health_querycache_hitrate':
    command_line => "${nrpe} -c check_mysql_health_querycache_hitrate",
  }
  nagios_command { 'check_nrpe_mysql_health_querycache_lowmem_prunes':
    command_line => "${nrpe} -c check_mysql_health_querycache_lowmem_prunes",
  }
  nagios_command { 'check_nrpe_mysql_health_keycache_hitrate':
    command_line => "${nrpe} -c check_mysql_health_keycache_hitrate",
  }
  nagios_command { 'check_nrpe_mysql_health_bufferpool_hitrate':
    command_line => "${nrpe} -c check_mysql_health_bufferpool_hitrate",
  }
  nagios_command { 'check_nrpe_mysql_health_bufferpool_wait_free':
    command_line => "${nrpe} -c check_mysql_health_bufferpool_wait_free",
  }
  nagios_command { 'check_nrpe_mysql_health_log_waits':
    command_line => "${nrpe} -c check_mysql_health_log_waits",
  }
  nagios_command { 'check_nrpe_mysql_health_tablecache_hitrate':
    command_line => "${nrpe} -c check_mysql_health_tablecache_hitrate",
  }
  nagios_command { 'check_nrpe_mysql_health_table_lock_contention':
    command_line => "${nrpe} -c check_mysql_health_table_lock_contention",
  }
  nagios_command { 'check_nrpe_mysql_health_index_usage':
    command_line => "${nrpe} -c check_mysql_health_index_usage",
  }
  nagios_command { 'check_nrpe_mysql_health_tmp_disk_tables':
    command_line => "${nrpe} -c check_mysql_health_tmp_disk_tables",
  }
  nagios_command { 'check_nrpe_mysql_health_slow_queries':
    command_line => "${nrpe} -c check_mysql_health_slow_queries",
  }
  nagios_command { 'check_nrpe_mysql_health_slave_lag':
    command_line => "${nrpe} -c check_mysql_health_slave_lag",
  }
  nagios_command { 'check_nrpe_mysql_health_slave_io_running':
    command_line => "${nrpe} -c check_mysql_health_slave_io_running",
  }
  nagios_command { 'check_nrpe_mysql_health_slave_sql_running':
    command_line => "${nrpe} -c check_mysql_health_slave_sql_running",
  }
  nagios_command { 'check_nrpe_mysql_health_open_files':
    command_line => "${nrpe} -c check_mysql_health_open_files",
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
  }
  nagios_timeperiod { 'workhours':
    alias     => 'Normal Work Hours',
    monday    => $timeperiod_workhours,
    tuesday   => $timeperiod_workhours,
    wednesday => $timeperiod_workhours,
    thursday  => $timeperiod_workhours,
    friday    => $timeperiod_workhours,
  }
  nagios_timeperiod { 'none':
    alias => 'No Time Is A Good Time',
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

  # With selinux, adjustements are needed for nagiosgraph
  if $selinux == 'true' and $::selinux_enforced == 'true' {
    selinux::audit2allow { 'nagios':
      source => "puppet:///modules/${module_name}/messages.nagios",
    }
  }

}


class nagios::check::mysql_health (
  $args                     = undef,
  $check_period             = undef,
  $first_notification_delay = undef,
  $notification_period      = undef,
  $modes_enabled            = [],
  $modes_disabled           = [],
  $pkg                      = true,
  $ensure                   = undef,
  # Modes
  $args_connection_time          = '',
  $args_uptime                   = '',
  $args_threads_connected        = '',
  $args_threadcache_hitrate      = '',
  $args_querycache_hitrate       = '',
  $args_querycache_lowmem_prunes = '',
  $args_keycache_hitrate         = '',
  $args_bufferpool_hitrate       = '',
  $args_bufferpool_wait_free     = '',
  $args_log_waits                = '',
  $args_tablecache_hitrate       = '',
  $args_table_lock_contention    = '',
  $args_index_usage              = '',
  $args_tmp_disk_tables          = '',
  $args_slow_queries             = '',
  $args_slave_lag                = '',
  $args_slave_io_running         = '',
  $args_slave_sql_running        = '',
  $args_open_files               = '',
) {

  # Generic overrides
  if $check_period {
    Nagios_service { check_period => $::nagios_check_mysql_health_check_period }
  }
  if $first_notification_delay {
    Nagios_service { first_notification_delay => $::nagios_check_mysql_health_first_notification_delay }
  }
  if $notification_period {
    Nagios_service { notification_period => $::nagios_check_mysql_health_notification_period }
  }

  # Optional package containing the script
  if $pkg {
    $pkgname = $::operatingsystem ? {
      'Gentoo' => 'net-analyzer/nagios-check_mysql_health',
       default => 'nagios-plugins-mysql_health',
    }
    package { $pkgname:
      ensure => $ensure ? {
        'absent' => 'absent',
         default => 'installed',
      }
    }
  }

  Package <| tag == 'nagios-plugins-perl' |>

  nagios::check::mysql_health::mode { [
    'connection-time',
    'uptime',
    'threads-connected',
    'threadcache-hitrate',
    'querycache-hitrate',
    'querycache-lowmem-prunes',
    'keycache-hitrate',
    'bufferpool-hitrate',
    'bufferpool-wait-free',
    'log-waits',
    'tablecache-hitrate',
    'table-lock-contention',
    'index-usage',
    'tmp-disk-tables',
    'slow-queries',
    'slave-lag',
    'slave-io-running',
    'slave-sql-running',
    'open-files',
  ]:
  }

}


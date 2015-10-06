class nagios::check::postgres (
  $args                     = undef,
  $check_period             = undef,
  $first_notification_delay = undef,
  $notification_period      = undef,
  $modes_enabled            = [],
  $modes_disabled           = [],
  $pkg                      = true,
  $ensure                   = undef,
  $standby_mode             = false,
  $privileged_user          = 'postgres',
  $plugin                   = 'check_postgres',
  $custom_queries           = {},
  # Modes
  $args_archive_ready       = '',
  $args_autovac_freeze      = '',
  $args_backends            = '',
  $args_bloat               = '',
  $args_checkpoint          = '-w 300',
  $args_cluster_id          = '',
  $args_commitratio         = '',
  $args_connection          = '',
  $args_database_size       = '-w 1t',
  $args_disabled_triggers   = '',
  $args_disk_space          = '',
  $args_fsm_pages           = '',
  $args_fsm_relations       = '',
  $args_hitratio            = '',
  $args_hot_standby_delay   = '-w 10m',
  $args_last_analyze        = '',
  $args_last_vacuum         = '',
  $args_last_autoanalyze    = '',
  $args_last_autovacuum     = '',
  $args_listener            = '',
  $args_locks               = '',
  $args_logfile             = '',
  $args_new_version_bc      = '',
  $args_new_version_box     = '',
  $args_new_version_tnm     = '',
  $args_pgb_pool_cl_active  = '',
  $args_pgb_pool_cl_waiting = '',
  $args_pgb_pool_sv_active  = '',
  $args_pgb_pool_sv_idle    = '',
  $args_pgb_pool_sv_used    = '',
  $args_pgb_pool_sv_tested  = '',
  $args_pgb_pool_sv_login   = '',
  $args_pgb_pool_sv_maxwait = '',
  $args_pgbouncer_backends  = '',
  $args_pgbouncer_checksum  = '',
  $args_pgagent_jobs        = '',
  $args_prepared_txns       = '',
  $args_query_time          = '-w 2m',
  $args_same_schema         = '',
  $args_sequence            = '',
  $args_settings_checksum   = '',
  $args_slony_status        = '',
  $args_txn_idle            = '-w 15s -c 1m',
  $args_txn_time            = '-w 5m -c 10m',
  $args_txn_wraparound      = '',
  $args_version             = '',
  $args_wal_files           = '',
) {

  # Generic overrides
  if $check_period {
    Nagios_service { check_period => $::nagios_check_postgres_period }
  }
  if $first_notification_delay {
    Nagios_service { first_notification_delay => $::nagios_check_postgres_first_notification_delay }
  }
  if $notification_period {
    Nagios_service { notification_period => $::nagios_check_postgres_notification_period }
  }

  # The check is being executed via sudo
  file { '/etc/sudoers.d/nagios_check_postgres':
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    # We customize the user, the nagios plugin dir and few other things
    content => template('nagios/plugins/check_postgres-sudoers.erb'),
  }

  # Optional package containing the script
  if $pkg {
    $pkgname = 'nagios-plugins-postgres'
    $pkgensure = $ensure ? {
      'absent' => 'absent',
      default  => 'installed',
    }
    package { $pkgname: ensure => $pkgensure }
  }

  Package <| tag == 'nagios-plugins-perl' |>

  # Modes-specific definition
  nagios::check::postgres::mode { [
    'archive_ready',
    'autovac_freeze',
    'backends',
    'bloat',
    'checkpoint',
    'cluster_id',
    'commitratio',
    'connection',
    'database_size',
    'disabled_triggers',
    'disk_space',
    'fsm_pages',
    'fsm_relations',
    'hitratio',
    'hot_standby_delay',
    'last_analyze',
    'last_vacuum',
    'last_autoanalyze',
    'last_autovacuum',
    'listener',
    'locks',
    'logfile',
    'new_version_bc',
    'new_version_box',
    'new_version_cp',
    'new_version_pg',
    'new_version_tnm',
    'pgb_pool_cl_active',
    'pgb_pool_cl_waiting',
    'pgb_pool_sv_active',
    'pgb_pool_sv_idle',
    'pgb_pool_sv_used',
    'pgb_pool_sv_tested',
    'pgb_pool_sv_login',
    'pgb_pool_sv_maxwait',
    'pgbouncer_backends',
    'pgbouncer_checksum',
    'pgagent_jobs',
    'prepared_txns',
    'query_time',
    'same_schema',
    'sequence',
    'settings_checksum',
    'slony_status',
    'txn_idle',
    'txn_time',
    'txn_wraparound',
    'version',
    'wal_files',
  ]:
  }

  # Custom queries
  nagios::check::postgres::custom_query { keys($custom_queries): }

}


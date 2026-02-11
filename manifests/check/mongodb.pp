class nagios::check::mongodb (
  $ensure                       = undef,
  $package                      = $::nagios::params::python_mongo,
  # common args for all modes 'as-is' for the check script
  $args                         = '',
  # common args for all modes as individual parameters
  $user                         = undef,
  $pass                         = undef,
  $database                     = undef,
  $collection                   = undef,
  # modes selectively enabled and/or disabled
  $modes_enabled                = [],
  $modes_disabled               = [],
  # groups of modes selectively enabled or disabled
  $v2                           = true,
  $mmapv1                       = true,
  $replication                  = true,
  $sharding                     = true,
  # special, disable auth and modes
  $arbiter                      = false,
  # Modes
  $args_asserts                 = '',
  $args_chunks_balance          = '',
  $args_collection_indexes      = '',
  $args_collections             = '',
  $args_collection_size         = '',
  $args_collection_state        = '',
  $args_collection_storageSize  = '',
  $args_connect                 = '',
  $args_connections             = '',
  $args_connect_primary         = '',
  $args_current_lock            = '',
  $args_database_indexes        = '',
  $args_databases               = '',
  $args_database_size           = '',
  $args_flushing                = '',
  $args_index_miss_ratio        = '',
  $args_journal_commits_in_wl   = '',
  $args_journaled               = '',
  $args_last_flush_time         = '',
  $args_lock                    = '',
  $args_memory                  = '',
  $args_memory_mapped           = '',
  $args_opcounters              = '',
  $args_oplog                   = '',
  $args_page_faults             = '',
  $args_queries_per_second      = '',
  $args_queues                  = '',
  $args_replica_primary         = '',
  $args_replication_lag         = '',
  $args_replication_lag_percent = '',
  $args_replset_quorum          = '',
  $args_replset_state           = '',
  $args_row_count               = '',
  $args_tickets                 = '',
  $args_wt_cache                = '',
  $args_write_data_files        = '',
  # service
  $check_title              = $::nagios::client::host_name,
  $servicegroups            = 'mongodb',
  $check_period             = $::nagios::client::service_check_period,
  $contact_groups           = $::nagios::client::service_contact_groups,
  $first_notification_delay = $::nagios::client::service_first_notification_delay,
  $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  $notification_period      = $::nagios::client::service_notification_period,
  $use                      = $::nagios::client::service_use,
) {

  nagios::client::nrpe_plugin { 'check_mongodb':
    ensure  => $ensure,
    package => $package,
  }

  # Set options from parameters unless already set inside args
  if $args !~ /-u/ and $user != undef and $arbiter != true {
    $arg_u = "-u ${user} "
  } else {
    $arg_u = ''
  }
  if $args !~ /-p/ and $pass != undef and $arbiter != true {
    $arg_p = "-p ${pass} "
  } else {
    $arg_p = ''
  }
  if $args !~ /-d/ and $database != undef {
    $arg_d = "-d ${database} "
  } else {
    $arg_d = ''
  }
  if $args !~ /-c/ and $collection != undef {
    $arg_c = "-c ${collection} "
  } else {
    $arg_c = ''
  }
  $globalargs = strip("-D ${arg_u}${arg_p}${arg_d}${arg_c}${args}")

  # -----------------------------------------------------------
  # ENGINE DETECTION LOGIC
  # -----------------------------------------------------------
  # WiredTiger became the default in 3.2. MMAPv1 was removed in 4.2.
  # We use 3.2 as the cutoff to switch to "Modern" checks.
  if $::mongod_version and versioncmp($::mongod_version, '3.2') >= 0 {
    $use_modern_checks = true
  } else {
    # Fallback to legacy if version is undef or < 3.2
    $use_modern_checks = false
  }

  if $use_modern_checks {
    # --- MODERN MODE (WiredTiger) ---
    # We swap 'current_lock' and 'memory_mapped' for 'tickets' and 'wt_cache'
    $modes_base = [
      'asserts',
      'connect',
      'connections',
      'connect_primary',
      'memory',
      'opcounters',
      'page_faults',
      'queries_per_second',
      'queues',
      'tickets',   # Replaces current_lock/lock
      'wt_cache',  # Replaces memory_mapped
    ]
    # We forcefully disable legacy option groups even if they are set to true in params
    $modes_enabled_v2     = []
    $modes_enabled_mmapv1 = []

  } else {
    # --- LEGACY MODE (MMAPv1) ---
    $modes_base = [
      'asserts',
      'connect',
      'connections',
      'connect_primary',
      'current_lock',
      'memory',
      'memory_mapped',
      'opcounters',
      'page_faults',
      'queries_per_second',
      'queues',
    ]
    # Respect parameters for legacy groupings
    if $v2 != false {
      $modes_enabled_v2 = [ 'lock' ]
    } else {
      $modes_enabled_v2 = []
    }

    if $mmapv1 != false {
      $modes_enabled_mmapv1 = [
        'flushing',
        'index_miss_ratio',
        'journal_commits_in_wl',
        'journaled',
        'last_flush_time',
        'write_data_files',
      ]
    } else {
      $modes_enabled_mmapv1 = []
    }
  }
  # -----------------------------------------------------------

  $modes_replication = [
    'oplog',
    'replica_primary',
    'replication_lag',
    'replication_lag_percent',
    'replset_quorum',
    'replset_state',
  ]
  $modes_sharding = [
    'chunks_balance',
  ]

  # FIXME : It would make sense to be able to monitor multiple databases and
  # collections per node, though it's going to make everything more complicated
  $modes_database = [
    'database_indexes',
    'databases',
    'database_size',
  ]
  $modes_collection = [
    'collection_indexes',
    'collections',
    'collection_size',
    'collection_state',
    'collection_storageSize',
    'row_count',
  ]

  if $replication != false {
    $modes_enabled_replication = $modes_replication
  } else {
    $modes_enabled_replication = []
  }
  if $sharding != false {
    $modes_enabled_sharding = $modes_sharding
  } else {
    $modes_enabled_sharding = []
  }
  if $database != undef {
    $modes_enabled_database = $modes_database
  } else {
    $modes_enabled_database = []
  }
  if $collection != undef {
    $modes_enabled_collection = $modes_collection
  } else {
    $modes_enabled_collection = []
  }

  # Modes-specific definition
  $modes = $modes_base
  + $modes_enabled_v2
  + $modes_enabled_mmapv1
  + $modes_enabled_replication
  + $modes_enabled_sharding
  + $modes_enabled_database
  + $modes_enabled_collection

  # An arbiter has no data, so remove all checks which are *never* relevant
  $modes_arbiter = [
    'asserts',
    'connect',
    'connect_primary',
    'connections',
    'current_lock',
    'memory',
    'memory_mapped',
    'opcounters',
    'page_faults',
    'queues',
    'replset_quorum',
    'replset_state',
    'tickets',
    'wt_cache',
  ]

  if $arbiter == true {
    $modes_final = intersection($modes,$modes_arbiter)
  } else {
    $modes_final = $modes
  }

  nagios::check::mongodb::mode { $modes_final:
    ensure                   => $ensure,
    globalargs               => $globalargs,
    modes_enabled            => $modes_enabled,
    modes_disabled           => $modes_disabled,
    # service
    check_title              => $check_title,
    servicegroups            => $servicegroups,
    check_period             => $check_period,
    contact_groups           => $contact_groups,
    first_notification_delay => $first_notification_delay,
    max_check_attempts       => $max_check_attempts,
    notification_period      => $notification_period,
    use                      => $use,
  }

}
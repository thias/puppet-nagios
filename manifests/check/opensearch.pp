class nagios::check::opensearch (
  # Absent by default for testing
  Enum['present','absent']           $ensure                   = 'present',
  String                             $args                     = '',
  Optional[String]                   $host                     = '127.0.0.1',
  Optional[String]                   $port                     = undef,
  Optional[String]                   $node                     = undef,
  Optional[Integer]                  $expected_nodes           = undef,
  Optional[String]                   $user                     = 'admin',
  Optional[String]                   $pass                     = 'admin',
  Array[String]                      $modes_enabled            = [],
  Array[String]                      $modes_disabled           = [],
  Optional[Hash[String, String]]     $mode_args                = {},
  Optional[String]                   $check_title              = $::nagios::client::host_name,
  Optional[String]                   $check_period             = $::nagios::client::service_check_period,
  Optional[String]                   $contact_groups           = $::nagios::client::service_contact_groups,
  Optional[String]                   $first_notification_delay = $::nagios::client::service_first_notification_delay,
  Optional[String]                   $max_check_attempts       = $::nagios::client::service_max_check_attempts,
  Optional[String]                   $notification_period      = $::nagios::client::service_notification_period,
  Optional[String]                   $use                      = $::nagios::client::service_use,
  Optional[String]                   $servicegroups            = $::nagios::client::service_servicegroups,
) {

  # Set options from parameters unless already set inside args
  if $args !~ /-H/ and $host != undef {
    $arg_h = "-H ${host} "
  } else {
    $arg_h = ''
  }
  if $args !~ /-P/ and $port != undef {
    $arg_p = "-P ${port} "
  } else {
    $arg_p = ''
  }
  if $args !~ /-N/ and $node != undef {
    $arg_n = "-N ${node} "
  } else {
    $arg_n = ''
  }
  if $args !~ /-u/ and $user != undef {
    $arg_u = "-u ${user} "
  } else {
    $arg_u = ''
  }
  if $args !~ /-p/ and $pass != undef {
    $arg_pass = "-p ${pass} "
  } else {
    $arg_pass = ''
  }
  if $args !~ /-E/ and $expected_nodes != undef {
    $arg_enodes = "-E ${expected_nodes} "
  } else {
    $arg_enodes = ''
  }

  $globalargs = strip("${arg_h}${arg_p}${arg_n}${arg_u}${arg_pass}${arg_enodes}${args}")

  # We need jq and bc installed
  $packages = [ 'bc' , 'jq' ]
  $packages.each |$package_name| {
    package { $package_name: ensure => installed }
  }

  # Custom check script
  file { '/usr/lib64/nagios/plugins/opensearch_check_nrpe.sh':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => "puppet:///modules/${module_name}/scripts/opensearch_check_nrpe.sh",
  }

  # Define Nagios checks for each mode
  $check_commands = {
    'cluster_status'                  => 'cluster_status',
    'nodes'                           => 'nodes',
    'unassigned_shards'               => 'unassigned_shards',
    'jvm_usage'                       => 'jvm_usage',
    'disk_usage'                      => 'disk_usage',
    'thread_pool_queues'              => 'thread_pool_queues',
    'no_replica_indices'              => 'no_replica_indices',
    'node_uptime'                     => 'node_uptime',
    'check_disk_space_for_resharding' => 'check_disk_space_for_resharding',
  }

  # Define Nagios checks for each mode
  # Need to solve the user and password for monitoring
  $check_commands.each |$mode, $command| {
    if !($mode in $modes_disabled) and (empty($modes_enabled) or $mode in $modes_enabled) {
      # Determine if mode_args is defined and has a key for the current mode
      $args_mode = $mode_args ? {
        undef   => '',
        default => $mode_args[$mode] ? {
          undef   => '',
          default => $mode_args[$mode]
        }
      }
      $fullargs = strip("${globalargs} ${args_mode}")

      nagios::client::nrpe_file { "check_opensearch_${mode}":
        ensure  => $ensure,
        plugin  => 'opensearch_check_nrpe.sh',
        args    => "$fullargs -t ${command}",
        require => File['/usr/lib64/nagios/plugins/opensearch_check_nrpe.sh'],
      }

      nagios::service { "check_opensearch_${mode}_${check_title}":
        ensure                   => $ensure,
        check_command            => "check_nrpe_opensearch_${mode}",
        service_description      => "opensearch_${mode}",
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
}


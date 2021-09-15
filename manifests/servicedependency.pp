# Define: nagios::servicedependency
#
# Wrap around the original nagios_servicedependency
# * To be able to export with the correct tag automatically
# * To be able to use defaults overridden or from facts
#
define nagios::servicedependency (
    $ensure                        = undef,
    $server                        = $nagios::client::server,
    $host_name                     = $nagios::client::host_name,
    $target                        = "/etc/nagios/puppet_checks.d/${host_name}.cfg",
    $service_description           = $name,
    $dependent_host_name           = $nagios::client::host_name,
    $dependent_service_description = undef,
    $execution_failure_criteria    = 'c',
    $notification_failure_criteria = 'w,c',

) {

    # Support an array of tags for multiple nagios servers
    $service_tag = regsubst($server,'^(.+)$','nagios-\1')
    @@nagios_servicedependency { $title:
        ensure                        => $ensure,
        host_name                     => $host_name,
        service_description           => $service_description,
        dependent_host_name           => $dependent_host_name,
        dependent_service_description => $dependent_service_description,
        execution_failure_criteria    => $execution_failure_criteria,
        notification_failure_criteria => $notification_failure_criteria,
        tag                           => $service_tag,
        target                        => $target,
    }
    @@nagios::file_perm { $title:
        target  => $target,
        tag     => $service_tag,
        require => Nagios_servicedependency[$title],
    }

}

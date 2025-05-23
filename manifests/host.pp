# Define: nagios::host
#
# Wrap around the original nagios_host :
# * To be able to export with the default tag
# * To be able to use defaults set by the module
#
# Note: the original nagios_host "alias" parameter is named "host_alias" here
# since otherwise it's interpreted as the puppet "alias" metaparameter.
#
define nagios::host (
    $server              = $nagios::client::server,
    $address             = $nagios::client::host_address,
    $host_alias          = $nagios::client::host_alias,
    $check_period        = $nagios::client::host_check_period,
    $check_command       = $nagios::client::host_check_command,
    $contact_groups      = $nagios::client::host_contact_groups,
    $hostgroups          = $nagios::client::host_hostgroups,
    $notes               = $nagios::client::host_notes,
    $notes_url           = $nagios::client::host_notes_url,
    $notification_period = $nagios::client::host_notification_period,
    $use                 = $nagios::client::host_use
) {

    # Fallback to defaults here, no problems passing empty values for the rest
    $final_address = $address ? {
        ''      => $facts['networking']['ip'],
        undef   => $facts['networking']['ip'],
        default => $address,
    }
    $swapsize = getvar('facts.memory.swap') ? {
      undef   => 'n/a',
      default => $facts['memory']['swap']['total'],
    }
    $final_notes = $notes ? {
        undef   => "<table><tr><th>OS</th><td>${facts['os']['name']} ${facts['os']['release']['full']}</td></tr><tr><th>CPU</th><td>${facts['processors']['physicalcount']} x ${facts['processors']['models'][0]}</td></tr><tr><th>Architecture</th><td>${facts['os']['architecture']}</td></tr><tr><th>Kernel</th><td>${facts['kernelrelease']}</td></tr><tr><th>Memory</th><td>${facts['memory']['system']['total']}</td></tr><tr><th>Swap</th><td>${swapsize}</td></tr></table>",
        default => $notes,
    }
    $final_notes_url = $notes_url ? {
        ''      => "/nagios/cgi-bin/status.cgi?host=${title}",
        undef   => "/nagios/cgi-bin/status.cgi?host=${title}",
        default => $notes_url,
    }
    $final_use = $use ? {
        ''      => 'linux-server',
        undef   => 'linux-server',
        default => $use,
    }

    @@nagios_host { $title:
        address             => $final_address,
        alias               => $host_alias,
        check_period        => $check_period,
        check_command       => $check_command,
        contact_groups      => $contact_groups,
        hostgroups          => $hostgroups,
        notes               => $final_notes,
        notes_url           => $final_notes_url,
        notification_period => $notification_period,
        use                 => $final_use,
        # Support an arrays of tags for multiple nagios servers
        tag                 => regsubst($server,'^(.+)$','nagios-\1'),
    }

}


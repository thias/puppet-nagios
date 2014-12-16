define nagios::check::swap ( $args = undef ) {

    # Generic overrides
    if $::nagios_check_swap_check_period != undef {
        Nagios_service { check_period => $::nagios_check_swap_check_period }
    }
    if $::nagios_check_swap_notification_period != undef {
        Nagios_service { notification_period => $::nagios_check_swap_notification_period }
    }

    # Service specific overrides
    if $::nagios_check_swap_warning != undef {
        $warning = $::nagios_check_swap_warning
    } else {
        $warning = '5%'
    }
    if $::nagios_check_swap_critical != undef {
        $critical = $::nagios_check_swap_critical
    } else {
        $critical = '2%'
    }

    Package <| tag == 'nagios-plugins-swap' |>

    nagios::client::nrpe_file { 'check_swap':
        args => "-w ${warning} -c ${critical} ${args}",
    }

    nagios::service { "check_swap_${title}":
        check_command       => 'check_nrpe_swap',
        service_description => 'swap',
        #servicegroups       => 'swap',
    }

}


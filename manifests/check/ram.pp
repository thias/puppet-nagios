define nagios::check::ram ( $args = undef ) {

    # Generic overrides
    if $::nagios_check_ram_check_period != undef {
        Nagios_service { check_period => $::nagios_check_ram_check_period }
    }
    if $::nagios_check_ram_notification_period != undef {
        Nagios_service { notification_period => $::nagios_check_ram_notification_period }
    }

    # Service specific overrides
    if $::nagios_check_ram_warning != undef {
        $warning = $::nagios_check_ram_warning
    } else {
        $warning = '10%'
    }
    if $::nagios_check_ram_critical != undef {
        $critical = $::nagios_check_ram_critical
    } else {
        $critical = '5%'
    }

    file { "${nagios::client::plugin_dir}/check_ram":
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => template('nagios/plugins/check_ram'),
        ensure  => $ensure,
    }

    nagios::client::nrpe_file { 'check_ram':
        args => "-w ${warning} -c ${critical} ${args}",
    }

    nagios::service { "check_ram_${title}":
        check_command       => 'check_nrpe_ram',
        service_description => 'ram',
        #servicegroups       => 'ram',
    }

}


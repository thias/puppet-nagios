# This is a sample on how to use the nagios::check defined type.
# The idea is to be able to have any module create a script that checks something
#   and pass this script to nagios to run it.
# Parameters in the executable could be implemented, but they present
#   a security risk and NRPE needs to have the option explicitly enabled.
# The executable could be potentially placed anywhere.
# If you include nagios::client before, you then have access to all its parameters.

class nagios::check::dummy (
) {

    # Write the check
    file { "/tmp/check_dummy.sh":
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => "#!/bin/bash\necho OK \nexit 0\n",
    }

    nagios::check {'dummy':
        executable   => '/tmp/check_dummy.sh',
    }
        
}


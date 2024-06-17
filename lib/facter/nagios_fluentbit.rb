# Create custom nagios_fluentbit if fluentbit binary is found

if FileTest.exists?('/usr/bin/fluent-bit')
  Facter.add('nagios_fluentbit') { setcode { true } }
end


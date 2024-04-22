# Create custom nagios_opensearch if opensearch binary is found

if FileTest.exists?('/usr/share/opensearch/bin/opensearch')
  Facter.add('nagios_opensearch') { setcode { true } }
end

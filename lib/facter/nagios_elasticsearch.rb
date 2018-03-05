# Create custom nagios_elasticsearch if elasticsearch binary is found

if FileTest.exists?('/usr/share/elasticsearch/bin/elasticsearch')
  Facter.add('nagios_elasticsearch') { setcode { true } }
end


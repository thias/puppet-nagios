# Create custom nagios_memcached if memcached is found

if FileTest.exists?('/usr/bin/memcached')
  Facter.add('nagios_memcached') { setcode { true } }
end


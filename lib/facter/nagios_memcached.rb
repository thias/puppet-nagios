# Create custom nagios_memcached if memcached is found

if File.exists?('/usr/bin/memcached')
  Facter.add('nagios_memcached') { setcode { true } }
end


# Create custom nagios_redis fact
if File.exists?('/usr/bin/redis-server')
  Facter.add('nagios_redis') { setcode { true } }
end

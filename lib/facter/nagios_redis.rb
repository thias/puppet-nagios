# Create custom nagios_redis fact
binaries_redis = [
  '/usr/bin/redis-server',
  '/usr/bin/valkey-server',
]
binaries_redis.each do |filename|
  if File.exists?(filename)
    Facter.add('nagios_redis') { setcode { true } }
  end
end

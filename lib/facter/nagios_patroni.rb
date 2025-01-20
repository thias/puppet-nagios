# Create custom nagios_patroni facts

binaries_patroni = [
  '/bin/patronictl',
  '/sbin/patronictl',
  '/usr/bin/patronictl',
  '/usr/sbin/patronictl',
  '/usr/local/bin/patronictl',
  '/usr/local/sbin/patronictl',
]

binaries_patroni.each do |filename|
  if FileTest.exists?(filename)
    Facter.add('nagios_patroni') { setcode { true } }
  end
end

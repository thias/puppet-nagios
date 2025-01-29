# Create custom nagios_haproxy fact

binaries = [
  '/usr/sbin/haproxy',
]

binaries.each do |filename|
  if File.exists?(filename)
    Facter.add('nagios_haproxy') { setcode { true } }
  end
end

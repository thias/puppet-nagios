# Create custom nagios_squid fact

binaries = [
  '/usr/sbin/squid',
]

binaries.each do |filename|
  if File.exists?(filename)
    Facter.add('nagios_squid') { setcode { true } }
  end
end

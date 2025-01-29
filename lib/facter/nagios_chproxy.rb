# Create custom nagios_chproxy facts

binaries_chproxy = [
  '/usr/bin/chproxy',
]

binaries_chproxy.each do |filename|
  if File.exists?(filename)
    Facter.add('nagios_chproxy') { setcode { true } }
  end
end

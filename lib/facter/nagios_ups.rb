# Create custom nagios_ups fact

binaries = [
  '/bin/nut-scanner',
]

binaries.each do |filename|
  if File.exists?(filename)
    Facter.add('nagios_ups') { setcode { true } }
  end
end

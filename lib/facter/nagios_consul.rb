# Create custom nagios_consul facts

binaries_consul = [
  '/bin/consul',
]

binaries_consul.each do |filename|
  if File.exists?(filename)
    Facter.add('nagios_consul') { setcode { true } }
  end
end


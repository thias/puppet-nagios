# Create custom nagios_aerospike facts

binaries_aerospike = [
  '/usr/bin/asd',
]

binaries_aerospike.each do |filename|
  if File.exists?(filename)
    Facter.add('nagios_aerospike') { setcode { true } }
  end
end


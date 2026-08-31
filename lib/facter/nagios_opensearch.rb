# Create custom nagios_opensearch if opensearch binary is found

binaries = [
  '/usr/share/opensearch/bin/opensearch',
  '/opt/opensearch/bin/opensearch',
  '/opt/opensearch/current/bin/opensearch'
  ]

binaries.each do |filename|
  if File.exists?(filename)
    Facter.add('nagios_opensearch') { setcode { true } }
  end
end
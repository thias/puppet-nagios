# Create custom nagios_syncthing if syncthing binary is found

if File.exists?('/usr/bin/syncthing')
  Facter.add('nagios_syncthing') { setcode { true } }
end


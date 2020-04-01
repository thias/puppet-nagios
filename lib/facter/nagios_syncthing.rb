# Create custom nagios_syncthing if syncthing binary is found

if FileTest.exists?('/usr/bin/syncthing')
  Facter.add('nagios_syncthing') { setcode { true } }
end


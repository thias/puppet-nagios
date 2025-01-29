# Create custom nagios_moxi fact if moxi is found

if File.exists?('/opt/moxi/bin/moxi')
  Facter.add('nagios_moxi') { setcode { true } }
end


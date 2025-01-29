# Create custom nagios_ipa_replication if ipa-server is found

if File.exists?('/usr/sbin/ipactl')
  Facter.add('nagios_ipa_server') { setcode { true } }
end


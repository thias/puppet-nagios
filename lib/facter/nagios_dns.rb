# Create custom nagios_dns_<exename> facts for each daemon found
# + create a main nagios_dns fact if one or more is present

binaries = [
  '/usr/sbin/named',
  '/usr/bin/tinydns',
]

mainfact = false
binaries.each do |filename|
  if FileTest.exists?(filename)
    mainfact = true
    # Create a specific nagios_dns_<exename> fact
    Facter.add('nagios_dns_' + filename[/[^\/]+$/]) { setcode { true } }
  end
end
if mainfact == true
  Facter.add('nagios_dns') { setcode { true } }
end


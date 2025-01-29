# Create custom nagios_mysqld fact

binaries = [
  '/usr/sbin/mysqld',
  '/usr/libexec/mysqld',
  '/usr/local/mysql/bin/mysqld',
]

binaries.each do |filename|
  if File.exists?(filename)
    Facter.add('nagios_mysqld') { setcode { true } }
  end
end


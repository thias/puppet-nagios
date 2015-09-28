# Create custom nagios_postgres fact

binaries = [
  '/opt/citusdb/4.0/bin/postgres',
  '/usr/pgsql-9.4/bin/postgres',
  '/usr/bin/postgres',
]

binaries.each do |filename|
  if FileTest.exists?(filename)
    Facter.add('nagios_postgres') { setcode { true } }
  end
end


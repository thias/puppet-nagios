# Create custom nagios_postgres facts

binaries_postgres = [
  '/opt/citusdb/4.0/bin/postgres',
  '/usr/pgsql-9.4/bin/postgres',
  '/usr/bin/postgres',
]

binaries_pgbouncer = [
  '/usr/bin/pgbouncer',
]

binaries_postgres.each do |filename|
  if FileTest.exists?(filename)
    Facter.add('nagios_postgres') { setcode { true } }
  end
end

binaries_pgbouncer.each do |filename|
  if FileTest.exists?(filename)
    Facter.add('nagios_postgres_pgbouncer') { setcode { true } }
  end
end


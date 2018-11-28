# Create custom nagios_clickhouse facts

binaries_clickhouse = [
  '/usr/bin/clickhouse-server',
]
cluster_name_file = '/var/lib/clickhouse/cluster_name'

binaries_clickhouse.each do |filename|
  if FileTest.exists?(filename)
    Facter.add('nagios_clickhouse') { setcode { true } }
  end
end

if FileTest.exists?(cluster_name_file)
  cluster_name = File.read(cluster_name_file)
  Facter.add('nagios_clickhouse_cluster_name') { setcode { cluster_name } }
end

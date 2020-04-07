# Create custom nagios_zookeeper facts

dirs_zookeeper = [
  '/usr/share/java/zookeeper',
]
cluster_name_file = '/var/lib/zookeeper/cluster_name'

dirs_zookeeper.each do |filename|
  if FileTest.exists?(filename)
    Facter.add('nagios_zookeeper') { setcode { true } }
  end
end

if FileTest.exists?(cluster_name_file)
  cluster_name = File.read(cluster_name_file)
  Facter.add('nagios_zookeeper_cluster_name') { setcode { cluster_name } }
end

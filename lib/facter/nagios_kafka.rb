# Create custom nagios_kafka facts

binaries_kafka = [
  '/usr/bin/kafka-server-start',
]
cluster_name_file = '/var/lib/kafka/cluster_name'

binaries_kafka.each do |filename|
  if FileTest.exists?(filename)
    Facter.add('nagios_kafka') { setcode { true } }
  end
end

if FileTest.exists?(cluster_name_file)
  cluster_name = File.read(cluster_name_file)
  Facter.add('nagios_kafka_cluster_name') { setcode { cluster_name } }
end

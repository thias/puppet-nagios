# Create custom nagios_chingestor facts

binaries_chingestor = [
  '/usr/sbin/chingestor',
]
consumer_group_name_file = '/data/consumer_group'

binaries_chingestor.each do |filename|
  if FileTest.exists?(filename)
    Facter.add('nagios_chingestor') { setcode { true } }
    if FileTest.exists?(consumer_group_name_file)
      consumer_group_name = File.read(consumer_group_name_file)
      Facter.add('nagios_chingestor_consumer_group_name') { setcode { consumer_group_name } }
    end
  end
end


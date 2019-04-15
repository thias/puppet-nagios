# Create custom nagios_budumper facts

binaries_budumper = [
  '/usr/sbin/budumper',
]
consumer_group_name_file = '/data/consumer_group'

binaries_budumper.each do |filename|
  if FileTest.exists?(filename)
    Facter.add('nagios_budumper') { setcode { true } }
    if FileTest.exists?(consumer_group_name_file)
      consumer_group_name = File.read(consumer_group_name_file)
      Facter.add('nagios_budumper_consumer_group_name') { setcode { consumer_group_name } }
    end
  end
end


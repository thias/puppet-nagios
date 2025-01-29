# Create custom nagios_rabbitmq fact
if File.exists?('/sbin/rabbitmq-server')
  Facter.add('nagios_rabbitmq') { setcode { true } }
end

if Facter::Core::Execution.which('rabbitmqctl')
  rabbitmq_nodename = Facter::Core::Execution.execute('rabbitmqctl status 2>&1')
  Facter.add(:nagios_rabbitmq_nodename) { setcode {
      %r{^Status of node '?([\w\.]+@[\w\.\-]+)'? \.+$}.match(rabbitmq_nodename)[1]
  }}
  rabbitmq_vhosts = Facter::Core::Execution.execute('rabbitmqctl list_vhosts 2>&1').gsub(/^Listing vhosts \.\.\.$\n/,'').split(/\n/)
  Facter.add('nagios_rabbitmq_vhosts') { setcode { rabbitmq_vhosts } }
end

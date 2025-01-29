# Create custom nagios_couchbase fact if couchbase is found

if File.exists?('/opt/couchbase/bin/cbstats')
  Facter.add('nagios_couchbase') { setcode { true } }
end


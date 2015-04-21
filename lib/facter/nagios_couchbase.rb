# Create custom nagios_couchbase fact if couchbase is found

if FileTest.exists?('/opt/couchbase/bin/cbstats')
  Facter.add('nagios_couchbase') { setcode { true } }
end


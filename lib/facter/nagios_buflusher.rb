# Create custom nagios_buflusher facts

binaries_buflusher = [
  '/usr/sbin/buflusher',
]
binaries_buflusher.each do |filename|
  if FileTest.exists?(filename)
    Facter.add('nagios_buflusher') { setcode { true } }
  end
end


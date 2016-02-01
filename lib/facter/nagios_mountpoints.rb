# Facter to detect if there is a glusterfs mount in /etc/fstab

# Same strings as checked from the check_mountpoints script
fstypes = [ 'nfs', 'nfs4', 'davfs', 'cifs', 'fuse', 'glusterfs', 'ocfs2', 'lustre' ]
fstypes_found = []

if File.exist? '/etc/fstab'
  File.open('/etc/fstab') do |io|
    io.each do |line|
      line.strip!
      # Skip lines starting with #
      next if line.start_with? '#'
      fstype = line.split[2]
      # Build array of found matching fstypes
      if fstypes.include? fstype
        next if fstypes_found.include? fstype
        fstypes_found << fstype
      end

    end
  end
  
  if ! fstypes_found.empty?
    # Create the fact
    Facter.add('nagios_mountpoints') { setcode { fstypes_found.join(',') } }
  end

end


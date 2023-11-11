define nagios::file_perm (
  $target,
) {
  # Work around a puppet bug where created files are 600 root:root
  # Also, restart service after resources are purged
  $file_params = {
    ensure => 'present',
    owner  => 'root',
    group  => 'nagios',
    mode   => '0640',
    audit  => 'content',
    notify => Service['nagios'],
  }
  ensure_resource('file', $target, $file_params)

}

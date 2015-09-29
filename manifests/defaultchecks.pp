# Main class for checks, *ONLY* meant to be included from nagios::client
# since it relies on variables from that class' scope.
#
class nagios::defaultchecks {

  # We are checking facts, which are strings (not booleans!)
  # lint:ignore:quoted_booleans lint:ignore:2sp_soft_tabs

  if $::nagios_check_disk_disable != 'true' {
    nagios::check::disk { $nagios::client::host_name: }
  }
  if $::nagios_check_ping_disable != 'true' {
    nagios::check::ping { $nagios::client::host_name: }
  }
  # Conditional checks, enabled based on custom facts
  if $::nagios_check_httpd_disable != 'true' and
     $::nagios_httpd {
    nagios::check::httpd { $nagios::client::host_name: }
  } else {
    nagios::check::httpd { $nagios::client::host_name: ensure => absent }
  }
  if $::nagios_check_megaraid_sas_disable != 'true' and
     $::nagios_pci_megaraid_sas {
    nagios::check::megaraid_sas { $nagios::client::host_name: }
  } else {
    nagios::check::megaraid_sas { $nagios::client::host_name: ensure => absent }
  }
  if $::nagios_check_mptsas_disable != 'true' and
     $::nagios_pci_mptsas {
    nagios::check::mptsas { $nagios::client::host_name: }
  } else {
    nagios::check::mptsas { $nagios::client::host_name: ensure => absent }
  }
  if $::nagios_check_nginx_disable != 'true' and
     $::nagios_httpd_nginx {
    nagios::check::nginx { $nagios::client::host_name: }
  } else {
    nagios::check::nginx { $nagios::client::host_name: ensure => absent }
  }
  if $::nagios_check_membase_disable != 'true' and
     $::nagios_membase {
    nagios::check::membase { $nagios::client::host_name: }
  } else {
    nagios::check::membase { $nagios::client::host_name: ensure => absent }
  }
  if $::nagios_check_couchbase_disable != 'true' and
     $::nagios_couchbase {
    nagios::check::couchbase { $nagios::client::host_name: }
  } else {
    nagios::check::couchbase { $nagios::client::host_name: ensure => absent }
  }
  if $::nagios_check_moxi_disable != 'true' and
     $::nagios_moxi {
    nagios::check::moxi { $nagios::client::host_name: }
  } else {
    nagios::check::moxi { $nagios::client::host_name: ensure => absent }
  }

  # lint:endignore

}


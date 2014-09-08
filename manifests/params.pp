# Class: nagios::params
#
# Parameters for and from the nagios module.
#
class nagios::params {

  $libdir = $::architecture ? {
    'x86_64' => 'lib64',
    'amd64'  => 'lib64',
     default => 'lib',
  }

  # The easy bunch
  $nagios_service = 'nagios'
  $nagios_user    = 'nagios'
  # nrpe
  $nrpe_cfg_file  = '/etc/nagios/nrpe.cfg'
  $nrpe_command   = '$USER1$/check_nrpe -H $HOSTADDRESS$'
  $nrpe_options   = '-t 15'

  # Optional plugin packages, to be realized by tag where needed
  # Note: We use tag, because we can't use alias for 2 reasons :
  # * http://projects.puppetlabs.com/issues/4459
  # * The value of $alias can't be the same as $name
  $nagios_plugins_packages = [
    'nagios-plugins-disk',
    'nagios-plugins-file_age',
    'nagios-plugins-http',
    'nagios-plugins-ide_smart',
    'nagios-plugins-ifstatus',
    'nagios-plugins-linux_raid',
    'nagios-plugins-load',
    'nagios-plugins-log',
    'nagios-plugins-mailq',
    'nagios-plugins-mysql',
    'nagios-plugins-ntp',
    'nagios-plugins-perl',
    'nagios-plugins-pgsql',
    'nagios-plugins-procs',
    'nagios-plugins-sensors',
    'nagios-plugins-swap',
    'nagios-plugins-users',
  ]

  case $::operatingsystem {
    'RedHat', 'Fedora', 'CentOS', 'Scientific': {
      $nrpe_package       = [ 'nrpe', 'nagios-plugins' ]
      $nrpe_service       = 'nrpe'
      $nrpe_user          = 'nrpe'
      $nrpe_group         = 'nrpe'
      $nrpe_pid_file      = hiera('nagios::params::nrpe_pid_file','/var/run/nrpe.pid')
      $nrpe_cfg_dir       = hiera('nagios::params::nrpe_cfg_dir','/etc/nrpe.d')
      $plugin_dir         = hiera('nagios::params::plugin_dir',"/usr/${libdir}/nagios/plugins")
      $pid_file           = hiera('nagios::params::pid_file','/var/run/nagios.pid')
      $megaclibin         = '/usr/sbin/MegaCli'
      $perl_memcached     = 'perl-Cache-Memcached'
      @package { $nagios_plugins_packages:
        ensure => installed,
        tag    => $name,
      }
    }
    'Gentoo': {
      $nrpe_package       = [ 'net-analyzer/nrpe' ]
      $nrpe_package_alias = 'nrpe'
      $nrpe_service       = 'nrpe'
      $nrpe_user          = 'nagios'
      $nrpe_group         = 'nagios'
      $nrpe_pid_file      = '/run/nrpe.pid'
      $nrpe_cfg_dir       = '/etc/nagios/nrpe.d'
      $plugin_dir         = "/usr/${libdir}/nagios/plugins"
      $pid_file           = '/run/nagios.pid'
      $megaclibin         = '/opt/bin/MegaCli'
      $perl_memcached     = 'dev-perl/Cache-Memcached'
      # No package splitting in Gentoo
      @package { 'net-analyzer/nagios-plugins':
        ensure => installed,
        tag    => $nagios_plugins_packages,
      }
    }
    'Debian': {
      $nrpe_package       = [ 'nagios-nrpe-server' ]
      $nrpe_package_alias = 'nrpe'
      $nrpe_service       = 'nagios-nrpe-server'
      $nrpe_user          = 'nagios'
      $nrpe_group         = 'nagios'
      $nrpe_pid_file      = '/run/nrpe.pid'
      $nrpe_cfg_dir       = '/etc/nagios/nrpe.d'
      $plugin_dir         = '/usr/lib/nagios/plugins'
      $pid_file           = '/run/nagios.pid'
      $megaclibin         = '/opt/bin/MegaCli'
      $perl_memcached     = 'libcache-memcached-perl'
      # No package splitting in Debian
      @package { 'nagios-plugins':
        ensure => installed,
        tag    => $nagios_plugins_packages,
      }
    }
    default: {
      $nrpe_package       = [ 'nrpe', 'nagios-plugins' ]
      $nrpe_service       = 'nrpe'
      $nrpe_user          = 'nrpe'
      $nrpe_group         = 'nrpe'
      $nrpe_pid_file      = hiera('nagios::params::nrpe_pid_file','/var/run/nrpe.pid')
      $nrpe_cfg_dir       = hiera('nagios::params::nrpe_cfg_dir','/etc/nagios/nrpe.d')
      $plugin_dir         = hiera('nagios::params::plugin_dir','/usr/libexec/nagios/plugins')
      $pid_file           = hiera('nagios::params::pid_file','/var/run/nagios.pid')
      $megaclibin         = hiera('nagios::params::megaclibin','/usr/sbin/MegaCli')
      $perl_memcached     = hiera('nagios::params::perl_memcached','perl-Cache-Memcached')
      @package { $nagios_plugins_packages:
        ensure => installed,
        tag    => $name,
      }
    }
  }

}


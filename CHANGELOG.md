#### 2016-03-22 - 1.0.10
* Include slack_plugin (#77, @lisuml).

#### 2016-02-09 - 1.0.9
* Require socat package for the moxi check.
* Include SELinux messages for moxi check through UNIX socket.

#### 2016-02-01 - 1.0.8
* Convert all relevant checks to classes, improving hiera override support.
* Add parameter to disable the default checks (#64, @rwf14f).
* Update ntp_time check to better handle defaults.
* Add server *_timeout parameters (#65, @zxjinn).
* Use ensure_packages for mailx server package (#70, @vchepkov).
* Include hpsa check for HP Smart Array RAID controllers (#73, @forgodssake).
* Exclude all loopback addresses from nagios_ipaddress6 fact.
* Remove obsolete membase check, product has been renamed to couchbase.
* Include mongodb checks.
* Update check_ram to use MemAvailable when available (RHEL7+).
* Update check_moxi to perform a deeper key SET+GET check by default.
* Include mountpoints check, rw check auto-enabled for network mounts.

#### 2015-10-06 - 1.0.7
* Include ping6 check, enable by default when a public IPv6 address is found.
* Include postgres checks (#59, @lisuml).
* Update/Fix nagios and nrpe default pid file location for Fedora/RHEL.
* Update check::swap to be a class, for hiera or ENC overrides.
* Support ppc64 architecture (#56, @hamzy).
* Disable missing nagios-plugins-mysql_health on Debian/Ubuntu (#56, @hamzy).
* Add nrpe_debug parameter (#57, @mmedvede).
* Add cfg_append param for appending lines to nagios.cfg (#58, @zxjinn).
* Decouple management of Apache virtual host (#61).

#### 2015-04-28 - 1.0.6
* Fix check::ntp_type when no -H is in args (#50, @raiblue).
* Convert all 'true' facts to booleans, keep compat with legacy paser.

#### 2015-04-01 - 1.0.5
* Code cleanups to make puppet lint a bit happier.

#### 2015-04-01 - 1.0.4
* Update check::ram to be a class, for hiera or ENC overrides.
* Update check::ntp_time to be a class, use more generic 0.pool.ntp.org.
* Add Amazon Linux support (#45).
* Fix Debian defaults and enable hiera overrides (#42, @davideagle).
* Fix some more '' vs. undef in default parameters from facts.
* Fix some more '' vs. undef in server and nagiosgraph classes.
* Add enable_flap_detection server parameter.
* Change ntp_time to become UNKNOWN instead of CRITICAL when it times out.

#### 2014-12-16 - 1.0.3
* Add sshd check (#30, @alexharv074).
* Update apache_httpd to the recent class (requires 0.5.0+).
* Fixes for future parser compatibility.
* Replace Modulefile with metadata.json.
* Clean up to make puppet lint happy.

#### 2014-09-16 - 1.0.2
* Fix the linux-server host template to have 24x7 notifications by default.
* Fix check_proc typo in server.pp (#37, @alexharv074).
* Make the ntp check server configurable (#36, @alexharv074).

#### 2014-09-15 - 1.0.1
* Fix to not install perl bindings package when memcached check is disabled.

#### 2014-09-09 - 1.0.0
* Update nagiosgraph.pp to use the same $apache_allowed_from as server.
* Fix main default httpd configuration file.
* Add /usr/sbin/mysqld to the list of locations for the mysqld fact.
* Include new http check using the http plugin.
* New nrpe_service definition (#23, @thomasvs).
* Allow specifying a megacli version to pin (#35, @thomasvs).
* Add results_limit parameter for cgi.cfg (#32, @alexharv074).
* Add Debian support for nrpe (#26, @davideagle).
* Add memcached check and plugin.
* Add conntrack check and plugin.
* Fix original_args in disk check and exclude cgroup mount by default.

#### 2014-06-03 - 0.4.7
* Update nrpe messages file.

#### 2014-05-26 - 0.4.6
* Update nrpe messages file.

#### 2014-05-05 - 0.4.5
* Update params.pp for CentOS, add pid_file (paths should match EPEL packages).
* Update and fix nrpe SELinux messages for RHEL7.

#### 2014-03-10 - 0.4.4
* Enable declaring all types from the server class, useful with hiera.
* Allow httpd_t to read nagios_spool_t files too.
* Add support for first_notification_delay in class based checks.

#### 2014-01-30 - 0.4.3
* Remove server udp sub-package, now part of the tcp package as of 1.4.15-2.
* Fix for useless $apache_allowed_from existence check (#12).
* Fix nagios pid file location.
* Fix typo in the default parameter variable names for dir_status check.
* Create overrideable resources instead of relying on templates.cfg.

#### 2013-12-10 - 0.4.2
* Add $::nagios_client fact for all nagios client nodes.

#### 2013-12-10 - 0.4.1
* Fix variable name in README (Anton Babenko).
* Make the megaclibin from check::megaraid_sas configurable.
* Update check::load to become a class.
* Add new check::load default values for over 16 CPUs.

#### 2013-07-18 - 0.4.0
* Include mysql_health checks, implemented in a more modern way

#### 2013-05-29 - 0.3.2
* Update check_dir_status to also check dir timestamp when empty.
* Move leftover default checks from client.pp to defaultchecks.pp.

#### 2013-05-24 - 0.3.1
* Update SELinux messages file.
* Change the Gentoo nrpe.pid location, to match the current one.
* Include custom check_dir_status script.
* Update README.

#### 2012-09-19 - 0.3.0
* Add support for Fedora.
* Add support for host_check_command.
* Add support for service contact_groups.
* Fix check_nginx exit statuses (warning and critical were inverted).
* Fix check_disk with configfs on Fedora 17.
* Conditionalize libdir to support Fedora/EPEL plugins.
* Add check for socat presence when checking for moxi+socket.
* Create resource for the check_* parent resource to avoid race condition
* Add none timeperiod by default
* Gentoo nrpe has been renamed net-analyzer/nrpe
* Add !requiretty for the required sudo commands

#### 2012-05-23 - 0.2.0
* Clean up the module to match current puppetlabs guidelines.
* Add new params.pp and use it from nagios::client for Gentoo specifics.
* Renamed checks.pp to defaultchecks.pp to be more explicit.
* Removed var.pp as everything is inside client.pp now.
* Finished updating host.pp and service.pp wrappers, use them from client.pp.
* Remove package.pp and use tag + realize to work around duplicates.
* Renamed nagios::client::nrpe to nagios::client::nrpe_file, more explicit.
* Simplified the check_ping to have a single argument.


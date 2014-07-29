class nagios::plugin::http_perf {

  # Multiple checks need this file
  file { "${nagios::client::plugin_dir}/check_http_perf":
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template("${module_name}/plugins/check_http_perf"),
  }

}


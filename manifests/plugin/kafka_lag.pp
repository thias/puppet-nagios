class nagios::plugin::kafka_lag {

  # Multiple checks need this file
  file { "${nagios::client::plugin_dir}/check_kafka_lag":
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template("${module_name}/plugins/check_kafka_lag"),
  }

}



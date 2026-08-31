#!/bin/bash
# Default values
HOST="localhost"
PORT="9200"
USER=""
PASSWORD=""
SSL_VERIFY=true
WARN_THRESHOLD=""
CRIT_THRESHOLD=""
CURRENT_NODE=$(hostname)

# Valid types array
VALID_TYPES=(cluster_status nodes unassigned_shards jvm_usage disk_usage thread_pool_queues no_replica_indices node_uptime check_disk_space_for_resharding shard_capacity)

# Function to join array elements
join_by() {
  local IFS="$1"
  shift
  echo "$*"
}

# Function to print usage with descriptions for each check
print_usage() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -H <host>                     Specify the OpenSearch host. Default is 'localhost'."
  echo "  -P <port>                     Specify the OpenSearch port. Default is '9200'."
  echo "  -u <user>                     Specify the OpenSearch username."
  echo "  -p <password>                 Specify the OpenSearch password."
  echo "  -t <type>                     Specify the check type. Types are:"
  echo "                                  - cluster_status: Check the overall cluster status."
  echo "                                  - nodes: Check the number of nodes in the cluster."
  echo "                                  - unassigned_shards: Check for unassigned shards in the cluster."
  echo "                                  - jvm_usage: Check JVM memory usage."
  echo "                                  - disk_usage: Check disk space usage."
  echo "                                  - thread_pool_queues: Check thread pool queue sizes."
  echo "                                  - no_replica_indices: Check for indices without replicas."
  echo "                                  - node_uptime: Check if node uptime is less than 10 minutes."
  echo "                                  - check_disk_space_for_resharding: Check disk space for index resharding."
  echo "                                  - shard_capacity: Check cluster-wide shard limits."
  echo "  -k                            Skip SSL verification. Use with caution."
  echo "  -w <warning_threshold>        Set a warning threshold."
  echo "  -c <critical_threshold>       Set a critical threshold."
  echo "  -E <expected_node_count>      Specify the expected node count for the 'nodes' check."
  echo "  -N <node>                     Specify the node name. Defaults to the hostname."
  echo "  -h                            Display this help message and exit."
}

# Parse command-line options
while getopts ":H:P:u:p:N:E:t:w:W:c:C:kh" opt; do
  case ${opt} in
    H ) HOST=$OPTARG ;;
    P ) PORT=$OPTARG ;;
    u ) USER=$OPTARG ;;
    p ) PASSWORD=$OPTARG ;;
    N ) CURRENT_NODE=$OPTARG ;;
    E ) EXPECTED_NODE_COUNT=$OPTARG ;;
    t ) TYPE=$OPTARG ;;
    k ) SSL_VERIFY=false ;;
    w | W) WARN_THRESHOLD=$OPTARG ;;
    c | C) CRIT_THRESHOLD=$OPTARG ;;
    h ) print_usage; exit 0 ;;
    * ) print_usage; exit 3 ;;
  esac
done

# Verify required dependencies are installed before doing anything
for cmd in curl jq awk bc tr; do
  if ! command -v $cmd &> /dev/null; then
    echo "UNKNOWN: Required command '$cmd' is not installed on this system."
    exit 3 # UNKNOWN
  fi
done

# Verify if type is set
if [[ -z "$TYPE" ]]; then
  echo "Error: -t option is required."
  print_usage
  exit 3 # Unknown
fi

# Verify if type is valid
if ! [[ " ${VALID_TYPES[*]} " =~ " $TYPE " ]]; then
    echo "Invalid type specified. Valid types are: $(join_by ', ' "${VALID_TYPES[@]}")."
    exit 3 # Unknown
fi

# Function to validate threshold logic (ensures Warning is stricter than Critical)
validate_thresholds() {
  if [[ -n "$WARN_THRESHOLD" && -n "$CRIT_THRESHOLD" ]]; then
    if (( $(echo "$WARN_THRESHOLD >= $CRIT_THRESHOLD" | bc -l) )); then
      echo "UNKNOWN: Warning threshold ($WARN_THRESHOLD) must be less than Critical threshold ($CRIT_THRESHOLD)."
      exit 3 # UNKNOWN
    fi
  fi
}

# Construct URL and CURL options
OPENSEARCH_URL="https://${HOST}:${PORT}"
CREDENTIALS="$USER:$PASSWORD"

# Base CURL options for timeout handling
CURL_OPTS="-s --connect-timeout 10 --max-time 30"
if [[ $SSL_VERIFY == false ]]; then
  CURL_OPTS="$CURL_OPTS -k"
fi

# Verify connection and authentication early with detailed error checking
verify_connection_and_auth() {
  local url="$OPENSEARCH_URL/_cluster/health"
  local http_code
  local curl_status

  # Output only the HTTP code. Redirect curl errors to dev null.
  # Note: Purposely excluding -f here so we can manually catch 4xx/5xx HTTP codes.
  # Credentials are piped via stdin to hide them from the process list (ps aux).
  http_code=$(curl -o /dev/null $CURL_OPTS -w "%{http_code}" --config - "$url" 2>/dev/null <<EOF
user = "$CREDENTIALS"
EOF
  )
  curl_status=$?

  # 1. Check underlying network/curl errors first
  if [[ $curl_status -ne 0 ]]; then
    case $curl_status in
      6)  echo "CRITICAL: Could not resolve host $HOST." ;;
      7)  echo "CRITICAL: Connection refused to $HOST:$PORT. Is the OpenSearch service down?" ;;
      28) echo "CRITICAL: Connection timed out to $HOST:$PORT. Firewall issue or network drop?" ;;
      35) echo "CRITICAL: SSL/TLS handshake failed. Check certificates or use -k to bypass." ;;
      *)  echo "CRITICAL: Connection failed with internal CURL error code $curl_status." ;;
    esac
    exit 2 # CRITICAL
  fi

  # 2. Check application-level HTTP errors
  if [[ "$http_code" -eq 401 ]]; then
    echo "CRITICAL: Invalid authentication credentials (HTTP 401). Verify username and password."
    exit 2 # CRITICAL
  elif [[ "$http_code" -eq 403 ]]; then
    echo "CRITICAL: User lacks permissions to view cluster health (HTTP 403)."
    exit 2 # CRITICAL
  elif [[ "$http_code" -eq 503 ]]; then
    echo "CRITICAL: OpenSearch service is unavailable or still initializing (HTTP 503)."
    exit 2 # CRITICAL
  elif [[ "$http_code" -ne 200 ]]; then
    echo "UNKNOWN: Unexpected HTTP status code $http_code received from OpenSearch."
    exit 3 # UNKNOWN
  fi
}

# Run the enhanced verification right away
verify_connection_and_auth

# Enhanced CURL execution with error handling for subsequent calls
# Adds -f (fail on HTTP error) so we don't accidentally pass HTML error pages to jq
execute_curl() {
  local url=$1
  response=$(curl -f $CURL_OPTS --config - "$url" 2>&1 <<EOF
user = "$CREDENTIALS"
EOF
  )
  curl_status=$?

  if [[ $curl_status -ne 0 ]]; then
    echo "CRITICAL: CURL connection or HTTP request failed during check. Exit code: $curl_status"
    exit 2 # CRITICAL
  else
    echo "$response" | jq . > /dev/null 2>&1
    jq_status=$?
    if [[ $jq_status -ne 0 ]]; then
      echo "CRITICAL: Failed to parse JSON response: $response"
      exit 2 # CRITICAL
    fi
  fi

  echo "$response"
}

# Function to get cluster health
get_cluster_health() {
  local url="$OPENSEARCH_URL/_cluster/health"
  response=$(curl -f $CURL_OPTS --config - "$url" 2>&1 <<EOF
user = "$CREDENTIALS"
EOF
  )
  curl_status=$?

  if [[ $curl_status -ne 0 ]]; then
    echo "CRITICAL: Failed to retrieve cluster health from OpenSearch."
    exit 2 # CRITICAL
  else
    echo "$response" | jq . > /dev/null 2>&1
    jq_status=$?

    if [[ $jq_status -ne 0 ]]; then
      echo "CRITICAL: Failed to parse JSON response for cluster health."
      exit 2 # CRITICAL
    fi
  fi

  echo "$response"
}

# Adjusted function to get nodes stats optionally for a specific node
get_nodes_stats() {
  local node_name=$1
  local url="$OPENSEARCH_URL/_nodes/stats"
  if [[ -n "$node_name" ]]; then
    url="$OPENSEARCH_URL/_nodes/$node_name/stats"
  fi
  echo $(execute_curl "$url")
}

# Function to get disk space usage
check_disk_usage() {
  if [[ -z "$WARN_THRESHOLD" ]]; then WARN_THRESHOLD=70; fi
  if [[ -z "$CRIT_THRESHOLD" ]]; then CRIT_THRESHOLD=90; fi
  validate_thresholds

  local response=$(execute_curl "$OPENSEARCH_URL/_cat/allocation?format=json")
  local node_info=$(echo "$response" | jq -r --arg node "$CURRENT_NODE" '.[] | select(.node == $node)')
  local percent=$(echo "$node_info" | jq -r '.["disk.percent"] // "n/a"')

  if [[ "$node_info" == "" ]]; then
    echo "UNKNOWN: Node $CURRENT_NODE not found in the cluster."
    exit 3 # UNKNOWN
  elif [[ "$percent" == "n/a" ]]; then
    echo "UNKNOWN: Disk information for node $CURRENT_NODE is unavailable."
    exit 3 # UNKNOWN
  else
    local used=$(echo "$node_info" | jq -r '.["disk.used"]')
    local total=$(echo "$node_info" | jq -r '.["disk.total"]')
    local avail=$(echo "$node_info" | jq -r '.["disk.avail"]')
    local perf_data="'$CURRENT_NODE'_used=${used}; '$CURRENT_NODE'_total=${total}; '$CURRENT_NODE'_avail=${avail};"

    if [[ "$percent" -ge "$CRIT_THRESHOLD" ]]; then
      echo "CRITICAL: Disk usage on $CURRENT_NODE is critical: ${percent}% used | $perf_data"
      exit 2 # CRITICAL
    elif [[ "$percent" -ge "$WARN_THRESHOLD" ]]; then
      echo "WARNING: Disk usage on $CURRENT_NODE is high: ${percent}% used | $perf_data"
      exit 1 # WARNING
    else
      echo "OK: Disk usage on $CURRENT_NODE is within thresholds: ${percent}% used | $perf_data"
      exit 0 # OK
    fi
  fi
}

# Function to get thread pool queue size
check_thread_pool_queues() {
  local response=$(execute_curl "$OPENSEARCH_URL/_cat/thread_pool/search?h=node_name,queue&v")

  if [[ -z "$response" ]]; then
    echo "UNKNOWN: Unable to retrieve thread pool queue information."
    exit 3 # UNKNOWN
  fi

  local queue_size=$(echo "$response" | awk -v node="$CURRENT_NODE" '$1 == node {print $2}')

  if [[ -z "$queue_size" ]]; then
    echo "UNKNOWN: No data for node $CURRENT_NODE."
    exit 3 # UNKNOWN
  fi

  if [[ -n "$WARN_THRESHOLD" ]] && [[ "$queue_size" -gt "$WARN_THRESHOLD" ]]; then
    echo "WARNING: High search thread pool queue on $CURRENT_NODE: $queue_size"
    exit 1 # WARNING
  else
    echo "OK: Thread pool queue on $CURRENT_NODE is $queue_size | '$CURRENT_NODE'_queue=$queue_size;"
    exit 0 # OK
  fi
}

# Function to check for indices with no replicas
check_no_replica_indices() {
    local response=$(execute_curl "$OPENSEARCH_URL/_cat/indices?h=index,rep&s=index")
    local indices_with_no_replicas=$(echo "$response" | awk '$1 !~ /^\./ && $2 == "0" {print $1}')

    if [[ -n "$indices_with_no_replicas" ]]; then
        echo "CRITICAL: The following user indices have no replicas: $(echo $indices_with_no_replicas | tr '\n' ' ')"
        exit 2 # CRITICAL
    else
        echo "OK: All user indices have replicas."
        exit 0 # OK
    fi
}

# Function to check if uptime is less than 10 minutes
check_node_uptime() {
  local node_name=$1
  local node_stats=$(execute_curl "$OPENSEARCH_URL/_nodes/$node_name/stats")
  local uptime_ms=$(echo "$node_stats" | jq -r ".nodes[] | select(.name == \"$node_name\") | .jvm.uptime_in_millis")

  if ! [[ "$uptime_ms" =~ ^[0-9]+$ ]]; then
    echo "UNKNOWN: Unable to retrieve or validate uptime for node $node_name."
    exit 3 # UNKNOWN
  fi

  local uptime_minutes=$((uptime_ms / 60000))
  local days=$((uptime_ms / 86400000))
  local hours=$(( (uptime_ms % 86400000) / 3600000 ))
  local minutes_display=$(( (uptime_ms % 3600000) / 60000 ))
  local uptime_string="${days}d ${hours}h ${minutes_display}m"
  local perf_data="'uptime_minutes'=$uptime_minutes"

  if [[ "$uptime_minutes" -lt 10 ]]; then
    echo "WARNING: OpenSearch node $node_name uptime is less than 10 minutes ($uptime_string). | $perf_data"
    exit 1 # WARNING
  else
    echo "OK: OpenSearch node $node_name uptime is $uptime_string. | $perf_data"
    exit 0 # OK
  fi
}

# Function to check shard capacity
check_shard_capacity() {
  if [[ -z "$WARN_THRESHOLD" ]]; then WARN_THRESHOLD=80; fi
  if [[ -z "$CRIT_THRESHOLD" ]]; then CRIT_THRESHOLD=95; fi
  validate_thresholds

  local stats=$(execute_curl "$OPENSEARCH_URL/_cluster/stats")
  local total_shards=$(echo "$stats" | jq -r '.indices.shards.total // 0')
  local data_nodes=$(echo "$stats" | jq -r '.nodes.count.data // 0')

  if [[ -z "$data_nodes" || "$data_nodes" -le 0 ]]; then
    echo "CRITICAL: No data nodes reported by cluster — OpenSearch cluster likely unhealthy."
    exit 2
  fi

  local settings=$(execute_curl "$OPENSEARCH_URL/_cluster/settings?include_defaults=true")
  local mspn=$(echo "$settings" | jq -r '.persistent.cluster.max_shards_per_node // .transient.cluster.max_shards_per_node // .defaults.cluster.max_shards_per_node // empty')

  if [[ -z "$mspn" || "$mspn" == "null" ]]; then
    mspn=1000
  fi

  local max_total=$(( mspn * data_nodes ))

  if [[ "$max_total" -le 0 ]]; then
    echo "CRITICAL: Invalid shard ceiling (max_shards_per_node=$mspn, data_nodes=$data_nodes)."
    exit 2
  fi

  local used_pct=$(echo "scale=2; ($total_shards*100)/$max_total" | bc)
  local headroom=$(( max_total - total_shards ))
  local perf="total_shards=$total_shards;;;$max_total; max_shards=$max_total;;;0; used_pct=${used_pct}%;$WARN_THRESHOLD;$CRIT_THRESHOLD;0;100 headroom=$headroom;;;0;"

  if (( $(echo "$used_pct >= $CRIT_THRESHOLD" | bc -l) )); then
    echo "CRITICAL: Shard capacity used ${used_pct}% ($total_shards/$max_total). headroom=$headroom | $perf"
    exit 2
  elif (( $(echo "$used_pct >= $WARN_THRESHOLD" | bc -l) )); then
    echo "WARNING: Shard capacity used ${used_pct}% ($total_shards/$max_total). headroom=$headroom | $perf"
    exit 1
  else
    echo "OK: Shard capacity used ${used_pct}% ($total_shards/$max_total). headroom=$headroom | $perf"
    exit 0
  fi
}

# Perform checks based on type
case "$TYPE" in
  cluster_status)
    cluster_health=$(get_cluster_health)
    if [[ $? -ne 0 ]]; then return; fi
    cluster_status=$(echo "$cluster_health" | jq -r '.status')
    number_of_nodes=$(echo "$cluster_health" | jq -r '.number_of_nodes')
    perf_data="nodes=$number_of_nodes"
    case "$cluster_status" in
      green)
        echo "OK: Cluster status is GREEN. All systems functional. | $perf_data"
        exit 0
        ;;
      yellow)
        echo "WARNING: Cluster status is YELLOW. Data is available but some replicas are not allocated. | $perf_data"
        exit 1
        ;;
      red)
        echo "CRITICAL: Cluster status is RED. Data is not fully available due to unallocated shards. | $perf_data"
        exit 2
        ;;
      *)
        echo "UNKNOWN: Cluster status is UNKNOWN - $cluster_status. | $perf_data"
        exit 3 # UNKNOWN
        ;;
    esac
    ;;
  nodes)
    cluster_health=$(get_cluster_health)
    current_nodes=$(echo "$cluster_health" | jq -r '.number_of_nodes')
    perf_data="'current_nodes'=$current_nodes"
    if [[ -z "$EXPECTED_NODE_COUNT" ]]; then
      echo "INFO: Nodes = $current_nodes (No number of expected nodes provided) | $perf_data"
      exit 0
    else
      if [[ "$current_nodes" -lt "$EXPECTED_NODE_COUNT" ]]; then
        echo "WARNING: Number of nodes ($current_nodes) is below expected count ($EXPECTED_NODE_COUNT). | $perf_data"
        exit 1
      else
        echo "OK: Nodes = $current_nodes (Expected count met or exceeded) | $perf_data"
        exit 0
      fi
    fi
    ;;
  unassigned_shards)
    cluster_health=$(get_cluster_health)
    if [[ $? -ne 0 ]]; then exit 2; fi
    unassigned_shards=$(echo "$cluster_health" | jq -r '.unassigned_shards')

    if [[ -z "$WARN_THRESHOLD" ]]; then WARN_THRESHOLD=5; fi
    if [[ -z "$CRIT_THRESHOLD" ]]; then CRIT_THRESHOLD=10; fi
    validate_thresholds

    perf_data="'unassigned_shards'=$unassigned_shards;$WARN_THRESHOLD;$CRIT_THRESHOLD;0;"

    if ! [[ "$unassigned_shards" =~ ^[0-9]+$ ]]; then
      echo "CRITICAL: Unable to retrieve the number of unassigned shards. | $perf_data"
      exit 2
    fi

    if (( unassigned_shards < WARN_THRESHOLD )); then
      echo "OK: Number of unassigned shards is within threshold: $unassigned_shards | $perf_data"
      exit 0
    elif (( unassigned_shards >= WARN_THRESHOLD && unassigned_shards < CRIT_THRESHOLD )); then
      echo "WARNING: High number of unassigned shards: $unassigned_shards | $perf_data"
      exit 1
    else
      echo "CRITICAL: Very high number of unassigned shards: $unassigned_shards | $perf_data"
      exit 2
    fi
    ;;
  jvm_usage)
    if [[ -z "$WARN_THRESHOLD" ]]; then WARN_THRESHOLD=70; fi
    if [[ -z "$CRIT_THRESHOLD" ]]; then CRIT_THRESHOLD=90; fi
    validate_thresholds

    nodes_stats=$(get_nodes_stats "$CURRENT_NODE")
    jvm_heap_used_percent=$(echo "$nodes_stats" | jq -r ".nodes[] | select(.name == \"$CURRENT_NODE\") | .jvm.mem.heap_used_percent")

    if [[ -z "$jvm_heap_used_percent" || "$jvm_heap_used_percent" == "null" ]]; then
      echo "UNKNOWN: No JVM stats available for node $CURRENT_NODE."
      exit 3 # UNKNOWN
    fi

    perf_data="'jvm_heap_used_percent'=$jvm_heap_used_percent%;$WARN_THRESHOLD;$CRIT_THRESHOLD;0;100"

    if (( $(echo "$jvm_heap_used_percent < $WARN_THRESHOLD" | bc -l) )); then
      echo "OK: JVM Heap Used on $CURRENT_NODE is within threshold: ${jvm_heap_used_percent}% | $perf_data"
      exit 0
    elif (( $(echo "$jvm_heap_used_percent >= $WARN_THRESHOLD && $jvm_heap_used_percent < $CRIT_THRESHOLD" | bc -l) )); then
      echo "WARNING: JVM Heap Used on $CURRENT_NODE is high: ${jvm_heap_used_percent}% | $perf_data"
      exit 1
    else
      echo "CRITICAL: JVM Heap Used on $CURRENT_NODE is very high: ${jvm_heap_used_percent}% | $perf_data"
      exit 2
    fi
    ;;
  disk_usage) check_disk_usage ;;
  thread_pool_queues) check_thread_pool_queues ;;
  no_replica_indices) check_no_replica_indices ;;
  node_uptime) check_node_uptime "$CURRENT_NODE" ;;
  check_disk_space_for_resharding)
    cluster_stats=$(execute_curl "$OPENSEARCH_URL/_cluster/stats")
    total_disk_space=$(echo "$cluster_stats" | jq '.nodes.fs.total_in_bytes')
    available_disk_space=$(echo "$cluster_stats" | jq '.nodes.fs.available_in_bytes')
    number_of_data_nodes=$(echo "$cluster_stats" | jq '.nodes.count.data')

    if ((number_of_data_nodes > 1)); then
        space_required_per_node_after_resharding=$(( (total_disk_space - available_disk_space) / (number_of_data_nodes - 1) ))
        if (( space_required_per_node_after_resharding > available_disk_space )); then
            echo "WARNING: There might not be enough disk space for index resharding if a data node fails."
            exit 1
        else
            echo "OK: Sufficient disk space for index resharding after a data node failure."
            exit 0
        fi
    else
        echo "UNKNOWN: Insufficient data nodes to calculate disk space for resharding."
        exit 3 # UNKNOWN
    fi
    ;;
  shard_capacity) check_shard_capacity ;;
  *)
    echo "This check type is not implemented in the script. Please contact the administrator if you believe this is an error."
    exit 3 # UNKNOWN
    ;;
esac

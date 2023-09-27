#!/usr/bin/env bash

set -e

#shell variables
## color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
## script variables
container_id=$(basename $(cat /proc/1/cpuset))
container_id_short=${container_id:0:12}
service_name=prometheus
service_port=${LISTEN_PORT_HTTP}
healthcheck_http=${PROXY_CONSUL_CHECK}

if [[ $healthcheck_http == "" ]]; then
  echo "no consul"
  exit 0
fi

cat << EOF > /docker-entrypoint.d/consul_regist.json
{
  "ID": "${service_name}",
  "Name": "${service_name}",
  "Tags": ["docker","infra"],
  "Port": ${service_port},
  "Meta": {
    "Container_ID": "${container_id}",
    "Container_ID_Short": "${container_id_short}"
  },
  "Check": {
    "Name": "${service_name}_check",
    "HTTP": "${healthcheck_http}",
    "Method": "GET",
    "Timeout": "10s",
    "Interval": "10s",
    "TLSSkipVerify": true,
    "DeregisterCriticalServiceAfter": "10m"
  }
}
EOF

while true; do
  echo "Starting/Updating service registration ..."
  # res=$(curl --get http://consul:8500/v1/agent/services --data-urlencode 'filter=ID == "${service_name}"' 2>/dev/null)
  curl -X PUT -H "Content-Type: application/json" -d @/docker-entrypoint.d/consul_regist.json http://consul:8500/v1/agent/service/register  2>/dev/null
  if [[ "$?" != "0" ]]; then
    echo -e "${RED}Service registration in Consul was failed: ${res}${NC}"
    sleep 10s
  else
    echo -e "${GREEN}Service registration in Consul completed successfully${NC}"
    break
  fi
done
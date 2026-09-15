#!/bin/bash
set -e

# $1 = Virtual Service IP (VIP)
# $2 = Virtual Service Port (VPT)
# $3 = Real Server IP (RIP)
# $4 = Real Server Port (RPT)
# $5 = Check Source IP

export PATH=/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin

CLUSTERNAME="${HAPROXY_PROXY_NAME%%-*}"
RESULT=$(curl "http://localhost:8080/v1/primary?group=$CLUSTERNAME" 2>/dev/null | xargs)
test "${RESULT}" = "$HAPROXY_SERVER_NAME"

#!/bin/bash
set -Ceu

cd `dirname $0`

logrotate -s ./status_nginx ./logrotate_nginx.conf
logrotate -f -s ./status_tshark ./logrotate_tshark.conf
cat /dev/null >| /data/tshark/log/tcp.json

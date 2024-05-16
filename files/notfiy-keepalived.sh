#!/bin/bash
/usr/sbin/setenforce 0
TYPE=$1
NAME=$2
STATE=$3
case $STATE in
        "MASTER") /usr/bin/systemctl start haproxy haproxy_exporter
                  ;;
        "BACKUP") /usr/bin/systemctl stop haproxy haproxy_exporter
                  ;;
        "FAULT")  /usr/bin/systemctl stop haproxy haproxy_exporter
                  exit 0
                  ;;
esac
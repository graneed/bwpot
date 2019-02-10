#!/bin/bash
set -Ceu

mode="$1" 

if [ "$mode" = "set" ]; then
    /sbin/iptables -w -A INPUT -i lo -j ACCEPT
    /sbin/iptables -w -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    /sbin/iptables -w -A INPUT -p tcp --dport 60022 -j ACCEPT
    /sbin/iptables -w -A INPUT -p tcp -m multiport --dports 80,443,8080 -j ACCEPT
    /sbin/iptables -w -P INPUT DROP
    /sbin/iptables -w -P OUTPUT ACCEPT
    /sbin/iptables -w -P FORWARD DROP
else
    /sbin/iptables -w -P INPUT ACCEPT
    /sbin/iptables -w -P OUTPUT ACCEPT
    /sbin/iptables -w -P FORWARD DROP
    /sbin/iptables -w -D INPUT -i lo -j ACCEPT
    /sbin/iptables -w -D INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    /sbin/iptables -w -D INPUT -p tcp --dport 60022 -j ACCEPT
    /sbin/iptables -w -D INPUT -p tcp -m multiport --dports 80,443,8080 -j ACCEPT
fi

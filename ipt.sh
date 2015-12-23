#! /bin/bash

EXTIF=$1
INIF=""
INNET=""

iptables -F
iptables -X
iptables -Z
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT
iptables -A OUTPUT -p icmp -j ACCEPT

if [ -f ipt_deny.sh ]; then
    sh ipt_deny.sh
fi

if [ -f ipt_allow.sh ]; then
    sh ipt_allow.sh
fi

if [ -f ipt_http.sh ]; then
    sh ipt_http.sh
fi

iptables -A INPUT -i $EXTIF -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -i $EXTIF -p udp --dport 1701 -j ACCEPT
iptables -A INPUT -i $EXTIF -p udp --dport 500 -j ACCEPT
iptables -A INPUT -i $EXTIF -p udp --dport 4500 -j ACCEPT

# NAT
iptables -F -t nat
iptables -X -t nat
iptables -Z -t nat
iptables -t nat -P PREROUTING ACCEPT
iptables -t nat -P POSTROUTING ACCEPT
iptables -t nat -P OUTPUT ACCEPT


#iptables -A INPUT -i $INIF -j ACCEPT

iptables -t nat -A POSTROUTING -o $EXTIF -j MASQUERADE

service iptables save

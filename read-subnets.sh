#!/bin/bash

# Read IP addresses from the file /root/.subnets
while IFS= read -r ipaddress; do
    if [[ $ipaddress == *":"* ]]; then
        # IPv6 address
        echo "Adding IPv6 route: $ipaddress"
        ip -6 route add "$ipaddress"
    else
        # IPv4 address
        echo "Adding IPv4 route: $ipaddress"
        ip route add "$ipaddress"
    fi
done < /root/.subnets

#!/usr/bin/env python3

import boto3
import requests
import ipaddress
import argparse

def get_ipv4(s):
    r = s.get('https://ipv4.icanhazip.com/')
    r.raise_for_status()
    return ipaddress.ip_address(r.text.rstrip())

def get_ipv6(s):
    r = s.get('https://ipv6.icanhazip.com/')
    r.raise_for_status()
    return ipaddress.ip_address(r.text.rstrip())

def make_change_request(target, ttl, ipv4, ipv6):
    return {
        'Changes': [
            {
                'Action': 'UPSERT',
                'ResourceRecordSet': {
                    'ResourceRecords': [ { 'Value': str(ipv4) } ],
                    'Type': 'A',
                    'Name': target,
                    'TTL': ttl
                }
            },
            {
                'Action': 'UPSERT',
                'ResourceRecordSet': {
                    'ResourceRecords': [ { 'Value': str(ipv6) } ],
                    'Type': 'AAAA',
                    'Name': target,
                    'TTL': ttl
                }
            }
        ]
    }


parser = argparse.ArgumentParser()
parser.add_argument('-z', '--host-zone', required=True, help='Host zone ID')
parser.add_argument('-t', '--target', required=True, help='target domain name')
parser.add_argument('-l', '--ttl', default=3600, help='Time To Live')
args = parser.parse_args()

with requests.Session() as s:
    ipv4 = get_ipv4(s)
    ipv6 = get_ipv6(s)

client = boto3.client('route53')

response = client.change_resource_record_sets(
    HostedZoneId=args.host_zone,
    ChangeBatch=make_change_request(args.target, args.ttl, ipv4, ipv6)
)

#print(response)

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

#gist.file.sh
#!/bin/sh

update_r53() {
    HOSTED_ZONE_ID=$1
    TARGET=$2
    MY_IP=$3
    TYPE=$4
    TTL=$5
    TEMPFILE=/tmp/update-rr.json

    cat <<__JSON__ > $TEMPFILE
{
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "ResourceRecords": [ { "Value": "${MY_IP}" } ],
        "Type": "${TYPE}",
        "Name": "${TARGET}",
        "TTL": ${TTL}
      }
    }
  ]
}
__JSON__

    aws route53 change-resource-record-sets \
	    --hosted-zone-id ${HOSTED_ZONE_ID} \
	    --change-batch file://${TEMPFILE}

}

MY_IP=`wget -qO- https://httpbin.org/ip | jq .origin | tr -d \"`

update_r53 "XXXXXXXXXXXXX" mizuho.autch.net $MY_IP A 300
update_r53 "XXXXXXXXXXXXX" tnok.jp $MY_IP A 300


###

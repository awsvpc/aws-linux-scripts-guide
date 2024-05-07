#!/bin/bash

#In early development, sometimes you've got a hand-built instance, but you also don't want to leave it up all the time
# We've got an m4xl instance running Spinnaker (http://spinnaker.io) but we only really need it during the day
# As a cost-saving measure, we shut it down overnight.  However, we want it to be consistently accessible
# So this script is in a Jenkins job that runs every morning, 
# starting up the instance then updating its DNS record to the new IP.

#If you have multiple DNS records for a single instance, 
# you can safely run a second copy of the script with the ZONEID and RECORDSET updated appropriately.

### 
# SETTINGS
### 
INSTANCE_ID="i-0123456789abcdef0"
REGION="us-east-1"

ZONEID="<zone id goes here>"
RECORDSET="<record to update>"
TTL=300
COMMENT="Auto updating from Jenkins job on `date`"
# Change to AAAA if using an IPv6 address
TYPE="A"



#Shouldn't need to edit anything past here

aws ec2 start-instances --instance-ids $INSTANCE_ID --region $REGION

if [ $? != 0 ]; then
	echo "First start attempt failed, retrying for 5 more minutes."
	WAIT_COUNT=0
    AWS_EXIT_CODE=1
	while [ $WAIT_COUNT -lt 5 ] && [ $AWS_EXIT_CODE != 0 ] ; do
    	sleep 60
        let WAITCOUNT+=1
        aws ec2 start-instances --instance-ids $INSTANCE_ID --region $REGION
        AWS_EXIT_CODE=$?
    done
    if [ $AWS_EXIT_CODE != 0 ]; then
		echo "Retry count exceeded, instance can't start"
    	exit 1
    fi
fi

WAIT_TIMEOUT=300
#Find a way to wait for the instance to start
echo "Waiting for instance to boot"
echo "Checking if your aws cli supports the wait command"
let COUNT=0
if aws ec2 wait 2>&1 | grep "Invalid choice"; then 
  echo "No aws cli support, using shell to wait"
  while ! aws ec2 describe-instances --instance-ids $INSTANCE_ID --region $REGION | grep running; do
    if [ $COUNT -gt $WAIT_TIMEOUT ]; then
      echo "Timeout exceeded waiting for instance to start."
      exit 1
    fi
    sleep 5
    let COUNT+=5
  done
else
  echo "Using aws cli to wait"
  aws ec2 wait instance-running --instance-ids $INSTANCE_ID --region $REGION 
fi

#Update DNS with new public IP
IP=`aws ec2 describe-instances --instance-ids $INSTANCE_ID --region $REGION | grep PublicIpAddress | grep -o -P "\d+\.\d+\.\d+\.\d+" | grep -v '^10\.'`


# Adapted from https://gist.github.com/phybros/827aa561a44032dd1556

function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

IPFILE="update-route53.ip"

if ! valid_ip $IP; then
    echo "Invalid IP address: $IP"
    exit 1
fi

# Check if the IP has changed
if [ ! -f "$IPFILE" ]
    then
    touch "$IPFILE"
fi

if grep -Fxq "$IP" "$IPFILE"; then
    # code if found
    echo "IP is still $IP. Exiting"
    exit 0
else
    echo "IP has changed to $IP"
    # Fill a temp file with valid JSON
    TMPFILE=$(mktemp /tmp/dns-update.XXXXXXXX)
    cat > ${TMPFILE} << EOF
    {
      "Comment":"$COMMENT",
      "Changes":[
        {
          "Action":"UPSERT",
          "ResourceRecordSet":{
            "ResourceRecords":[
              {
                "Value":"$IP"
              }
            ],
            "Name":"$RECORDSET",
            "Type":"$TYPE",
            "TTL":$TTL
          }
        }
      ]
    }
EOF

    # Update the Hosted Zone record
    aws route53 change-resource-record-sets \
        --hosted-zone-id $ZONEID \
        --change-batch file://"$TMPFILE"

    # Clean up
    rm $TMPFILE
fi

# All Done - cache the IP address for next time
echo "$IP" > "$IPFILE"

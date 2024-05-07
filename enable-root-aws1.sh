#!/bin/bash -e
if [ $# -lt 2 ]; then
  echo "ERROR: Incorrect syntax."
  echo ""
  echo "Please use: ${0} <PATH_TO_SSH_PRIVATE_KEY> <EC2_IP_OR_HOSTNAME>"
  exit 1
fi
ssh -i ${1} ec2-user@${2} "if [ -f /proc/sys/net/ipv6/conf/all/disable_ipv6 ]; then sudo /sbin/sysctl -w net.ipv6.conf.all.disable_ipv6=1; fi"
ssh -i ${1} ec2-user@${2} "wget https://gist.githubusercontent.com/juliogonzalez/a577f6020c165d8840c3b6041d47aecd/raw/enable-root-aws.sh"
ssh -i ${1} ec2-user@${2} "sudo bash /home/ec2-user/enable-root-aws.sh"

#!/bin/bash

comm -23  <(aws ec2 describe-security-groups --query 'SecurityGroups[*].GroupId'  --output text | tr '\t' '\n'| sort) <(aws ec2 describe-network-interfaces --query 'NetworkInterfaces[*].Groups[*].GroupId' --output text| tr '\t' '\n' | sort | uniq)

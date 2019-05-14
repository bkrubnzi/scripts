#!/bin/bash

aws ec2 run-instances --image-id $IMAGE_NAME --count $COUNT --instance-type t2.micro --key-name $KEY_NAME --security-group-ids $SECURITY_GROUP --associate-public-ip-address --subnet-id $SUBNET_ID --user-data file://$SHELL_SCRIPT  --iam-instance-profile Arn="arn:aws:iam::$ACCOUNT_NUMBER:instance-profile/$PROFILE_NAME" --query 'Instances[0].[InstanceId,PrivateIpAddress]' --output text

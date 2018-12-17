#!/bin/bash
KEYS=`aws ec2 describe-key-pairs --region us-east-2 --query 'KeyPairs[*].KeyName' --output text | tr '\t' '\n'`;while IFS= read -r key;do echo $key;aws ec2 describe-instances --region us-east-2 --f
ilters Name=key-name,Values="$key" --query 'Reservations[*].Instances[*].InstanceId' --output table;done <<< "$KEYS"

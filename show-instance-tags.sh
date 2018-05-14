#!/bin/bash

IDS=`~/show-running-instances.sh | awk '{print $2}'`;while IFS= read -r id;do aws ec2 describe-tags --filter "Name=resource-id,Values=$id" --query "Tags[*].{Name: Key, Value: Value,ID: ResourceId}" --output text;done <<< "$IDS" | grep "Solution Owner"

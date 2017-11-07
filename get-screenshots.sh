#!/bin/bash

INTERESTING=`aws ec2 describe-instances --filter Name="instance-state-name",Values="running" --query "Reservations[*].Instances[*].{name: Tags[?Key=='Name'] | [0].Value, instance_id: InstanceId, ip_address: PrivateIpAddress, state: State.Name, OS: Platform}" --output text | grep -i windows | awk '{print $2}'`

while IFS= read -r instance; do
        aws ec2 get-console-screenshot --instance-id $instance --output json | jq '.ImageData' | perl -pi -e 's/\"//g' | base64 -d > "$instance.jpg"
done <<< "$INTERESTING"

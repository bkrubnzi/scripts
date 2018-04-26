#!/bin/bash

aws ec2 describe-instances --filter Name="instance-state-name",Values="running" --query "Reservations[*].Instances[*].{name: Tags[?Key=='Name'] | [0].Value, instance_id: InstanceId, ip_address: PrivateIpAddress, state: State.Name, OS: Platform}" --output text

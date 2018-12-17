#!/bin/bash

AMIS=`aws ec2 describe-images --region us-east-2 --owners self --output text  --query 'Images[*].ImageId' | sed 's/\t\t*/\n/g'`

while IFS= read -r ami;do
    echo "$ami";aws ec2 describe-instances --region us-east-2 --filters "Name=image-id,Values=$ami" --query "Reservations[*].Instances[*].InstanceId" --output text
done <<< "$AMIS"

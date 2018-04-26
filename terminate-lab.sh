#!/bin/bash

THIS=`~/show-running-instances.sh | grep LAB | awk '{print $2}' | tr '\n' ' '`
aws ec2 terminate-instances --instance-ids $THIS

#!/bin/bash
aws ec2 describe-addresses --query 'Addresses[?InstanceId==null]' --output text | tr '\t' '\n' | grep eipalloc

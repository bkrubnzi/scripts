#!/bin/bash

BUCKETS=`aws s3api list-buckets | jq -r .Buckets[].Name`; while IFS= read -r bucket;do COMMAND="s/___BUCKET___/$bucket/g";echo $COMMAND;perl -pi -e $COMMAND policy.txt;aws s3api put-bucket-policy --bucket $bucket --policy file://policy.txt;cat policy_restore.txt > policy.txt; done <<< "$BUCKETS"

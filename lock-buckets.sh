#!/bin/bash

cp lock-the-bucket.json lock-the-bucket_restore.json;BUCKETS=`aws s3api list-buckets | jq -r .Buckets[].Name`; while IFS= read -r bucket;do COMMAND="s/___BUCKET___/$bucket/g";echo $COMMAND;perl -pi -e $COMMAND lock-the-bucket.json;aws s3api put-bucket-policy --bucket $bucket --policy file://lock-the-bucket.json;cat lock-the-bucket_restore.json > lock-the-bucket.json; done <<< "$BUCKETS"

#!/bin/bash

BUCKETS=`aws s3api list-buckets | jq -r .Buckets[].Name | grep -v "qls-1040504-99c9300dd8467ace-status-f86vuwmin8du"`; while IFS= read -r bucket;do echo "iterating $bucket";OBJECTS=`aws s3api list-objects --bucket "$bucket" | jq -r .Contents[].Key`;while IFS= read -r object;do echo "Iterating Object $object";aws s3api put-object-acl --bucket "$bucket" --key "$object" --acl private;done <<< "$OBJECTS";done <<< "$BUCKETS";

#!/bin/bash
set -m

forkme() {
        if [ "$key" ]; then
            echo "Scanning object $key in $bucket..."
            OBJECT="aws s3api get-object-acl --bucket $bucket --key $key --output json"
            VIOLATOR=`eval $OBJECT | grep -c "http://acs.amazonaws.com/groups/global/AllUsers"`
            if [ $VIOLATOR -ne 0 ]; then
                OBJECT_VIOLATORS+=("$bucket:$key")
                echo "$bucket:$key violates policy" >> violators.txt
            fi
        fi
}

BUCKETS=`aws s3api list-buckets --output json | grep "Name" | grep -v "DisplayName" | awk -F ":" '{print $2}' | perl -pi -e 's/\"//g'`
BUCKET_VIOLATORS=()
OBJECT_VIOLATORS=()

while IFS= read -r bucket; do

    echo "Scanning policy for $bucket..."
    VIOLATOR=`aws s3api get-bucket-acl --bucket $bucket --output json | grep -c "http://acs.amazonaws.com/groups/global/AllUsers"`;
    if [ $VIOLATOR -ne 0 ]; then
    BUCKET_VIOLATORS+=("$bucket")
    echo "$bucket violates policy" >> violators.txt
    fi

    KEYS=`aws s3api list-objects --bucket $bucket --output json | grep "Key" | awk -F ":" '{print $2}' | perl -pi -e 's/[\,]//g'`
    while IFS= read -r key; do
        forkme $bucket $key &
        j=`jobs -p | wc -l`
        if [ $j -ge 5 ]; then
            for job in `jobs -p`; do
                wait $job
            done
        fi
    done <<< "$KEYS"
done <<< "$BUCKETS"



echo -e $BUCKET_VIOLATORS
echo -e "---"
echo -e $OBJECT_VIOLATORS

#Lists every single AWS command-line command, broken out by service

#!/bin/bash
aws ? > temp.txt 2>&1
SERVICES=`cat temp.txt | tr '|' '\n' | sed 's/ //g' | sed '1,8d'`
while IFS= read -r service; do
    SERVICE_APIS=`aws $service ? 2>&1 | tr '|' '\n' | sed 's/ //g' | sed '1,8d'`
    while IFS= read -r service_api; do
        echo "aws $service $service_api" >> aws_$service.txt
    done <<< "$SERVICE_APIS"
done <<< "$SERVICES"

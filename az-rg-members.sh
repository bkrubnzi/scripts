#!/bin/bash

AZ_GROUPS=`az group list | jq -r '.[] | .name'`

while IFS= read -r az_group
do
    NAMES=`az role assignment list --resource-group $az_group | jq -r '.[] | .properties.principalName'`
    echo "$az_group:"
    while IFS= read -r name
    do
        echo $name
    done <<< "$NAMES"
done <<< "$AZ_GROUPS"

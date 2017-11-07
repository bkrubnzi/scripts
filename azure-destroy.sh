NAME=`az group list | jq -r '.[].name'`;while IFS= read -r group;do az group delete --name $group;done <<< "$NAME"

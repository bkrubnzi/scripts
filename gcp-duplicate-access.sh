#Use this script to duplicate an old group's permissions to a new group
#gcp-duplicate-access.sh [OLD_GROUP] [NEW_GROUP]

#!/bin/bash
old_group="group:$1"
new_group="group:$2"
DOCUMENTS=`find [ROOT_FOLDER] -name "*.json"`

while IFS= read -r document; do
FOUND=`jq -r "try (.bindings[] | select (.members[]==\"$old_group\")| .members)" $document`
if [[ $FOUND ]]; then
  cat <<< $(jq "(.bindings[] | select(.members[]==\"$old_group\")).members |= . + [\"$new_group\"]" $document) > ${document}_new
  python -m json.tool ${document}_new > $document}_formatted
  mv ${document}_formatted ${document}_new
fi
done <<< "$DOCUMENTS"

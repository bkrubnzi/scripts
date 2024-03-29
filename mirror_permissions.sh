#!/bin/bash

# To mirror roles between two groups in GCP. First, set GROUP_TO_MIRROR to be the group whose permissions you want to mirror. Secondly, set NEW_GROUP to the group
# that will receive new roles based on the roles the current group has.


# format of mygroup@example.com
GROUP_TO_MIRROR=""
NEW_GROUP=""

find_children() {
                while IFS= read -r sub_folder;do
                        BINDINGS=`gcloud resource-manager folders get-iam-policy $sub_folder --flatten="bindings[].members" --filter="bindings.members:${GROUP_TO_MIRROR}" | grep role |sed -e 's/role: //'`
                        for role in ${BINDINGS}
                        do
                        gcloud resource-manager folders add-iam-policy-binding $sub_folder --quiet --member="group:${NEW_GROUP}" --role="${role}"
                        echo "Set ${role} on ${sub_folder} for ${NEW_GROUP}"
                        done
                        PROJECT_IDS=`gcloud projects list --filter=" parent.id: '$sub_folder' " --format json | jq -r '.[] | .projectId'`
                        if [ "$PROJECT_IDS" ]; then
                                while IFS= read -r project_id;do
                                        BINDINGS=`gcloud projects get-iam-policy $project_id --flatten="bindings[].members" --filter="bindings.members:${GROUP_TO_MIRROR}" | grep role |sed -e 's/role: //'`
                                        for role in ${BINDINGS}
                                        do
                                        gcloud projects add-iam-policy-binding $project_id --quiet --member="group:${NEW_GROUP}" --role="${role}"
                                        echo "Set ${role} on ${project_id} for ${NEW_GROUP}"
                                        done
                                done <<< "$PROJECT_IDS"
                        fi
                        SUB_FOLDERS=`gcloud resource-manager folders list --folder $sub_folder --format json | jq -r '.[] | .name' | sed -e 's/.*\///'`
                        if [ "$SUB_FOLDERS" ];then
                                find_children $SUB_FOLDERS
                        fi
                done <<< "$SUB_FOLDERS"
}



ORG_ID=`gcloud organizations list --format json | jq -r '.[] | .name' | sed -e 's/.*\///'`
ORG_NAME=`gcloud organizations describe $ORG_ID --format json | jq -r '.displayName'`
BINDINGS=`gcloud organizations get-iam-policy $ORG_ID --flatten="bindings[].members" --filter="bindings.members:${GROUP_TO_MIRROR}" | grep role |sed -e 's/role: //'`
for role in ${BINDINGS}
do
gcloud organizations add-iam-policy-binding $ORG_ID --quiet --member="group:${NEW_GROUP}" --role="${role}"
echo "Set ${role} on ${ORG_ID} for ${NEW_GROUP}"
done
SUB_FOLDERS=`gcloud resource-manager folders list --organization $ORG_ID --format json | jq -r '.[] | .name' | sed -e 's/.*\///'`
find_children $SUB_FOLDERS

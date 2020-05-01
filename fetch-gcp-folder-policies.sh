#!/bin/bash

find_children() {
                while IFS= read -r sub_folder;do
                        folder_name=`gcloud resource-manager folders describe $sub_folder --format json | jq -r '.displayName' | sed 's/\ /_/g'`
                        mkdir $folder_name
                        cd $folder_name
                        folder_policy_filename=$sub_folder"_"$folder_name"_policy.json"
                        gcloud resource-manager folders get-iam-policy $sub_folder --format json > $folder_policy_filename
                        PROJECT_IDS=`gcloud projects list --filter=" parent.id: '$sub_folder' " --format json | jq -r '.[] | .projectId'`
                        if [ "$PROJECT_IDS" ]; then
                                while IFS= read -r project_id;do
                                        gcloud projects get-iam-policy $project_id --format json > $project_id.json
                                done <<< "$PROJECT_IDS"
                        fi
                        SUB_FOLDERS=`gcloud resource-manager folders list --folder $sub_folder --format json | jq -r '.[] | .name' | sed -e 's/.*\///'`
                        if [ "$SUB_FOLDERS" ];then
                                find_children $SUB_FOLDERS
                        fi
                        cd ..
                done <<< "$SUB_FOLDERS"
}

ORG_ID=`gcloud organizations list --format json | jq -r '.[] | .name' | sed -e 's/.*\///'`
ORG_NAME=`gcloud organizations describe $ORG_ID --format json | jq -r '.displayName'`
mkdir $ORG_NAME
cd $ORG_NAME
SUB_FOLDERS=`gcloud resource-manager folders list --organization $ORG_ID --format json | jq -r '.[] | .name' | sed -e 's/.*\///'`
find_children $SUB_FOLDERS

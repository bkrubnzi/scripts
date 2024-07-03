set -m

find_children() {
        while IFS= read -r sub_folder;do
                tabs="$tabs    "
                folder_name=`gcloud resource-manager folders describe $sub_folder --format json | jq -r '.displayName' | sed 's/\ /_/g'`
                echo "$tabs Traversing $folder_name..."
                if [ ! -d $folder_name ]; then mkdir $folder_name;fi
                cd $folder_name
                PROJECT_IDS=`gcloud projects list --filter=" parent.id: '$sub_folder' " --format json | jq -r '.[] | .projectId'`
                if [ "$PROJECT_IDS" ]; then
                        while IFS= read -r project_id;do
                                tabs="$tabs    "
                                BUCKETS=`gcloud storage buckets list --project $project_id --format json`
                                if [ "$BUCKETS" != "[]" ];then
                                        echo "$tabs bucket exists in $project_id"
                                        echo "$BUCKETS" > $project_id.json
                                        HEADER="Name,Classification,Storage URL"
                                        BUCKETS_TABLE=`cat $project_id.json | jq -r '.[] | "\(.name),\(.data_classification),\(.storage_url)"'`
                                        echo $HEADER > $project_id.csv
                                        echo "$BUCKETS_TABLE" >> $project_id``.csv
                                else
                                        echo "$tabs no bucket in $project_id"
                                fi
                                tabs=${tabs:0:-4}
                        done <<< "$PROJECT_IDS"
                fi
                SUB_FOLDERS=`gcloud resource-manager folders list --folder $sub_folder --format json | jq -r '.[] | .name' | sed -e 's/.*\///'`
                if [ "$SUB_FOLDERS" ];then
                        find_children $SUB_FOLDERS
                fi
                tabs=${tabs:0:-4}
                cd ..
        done <<< "$SUB_FOLDERS"
}
trap ctrl_c INT

function ctrl_c() {
        echo "killing threads..."
        pkill -P $$
}

ORG_IDS=`gcloud organizations list --format json | jq -r '.[] | .name' | sed -e 's/.*\///'`
while IFS= read -r org_id;do
        ORG_NAME=`gcloud organizations describe $org_id --format json | jq -r '.displayName'`
        tabs=""
        echo "Traversing $ORG_NAME..."
        if [ ! -d $ORG_NAME ];then mkdir $ORG_NAME;fi
        cd $ORG_NAME
        SUB_FOLDERS=`gcloud resource-manager folders list --organization $org_id --format json | jq -r '.[] | .name' | sed -e 's/.*\///'`
        find_children $SUB_FOLDERS &
        j=`jobs -p | wc -l`
        if [ $j -ge 3 ]; then
            for job in `jobs -p`; do
                wait $job
            done
        fi
        cd ..
done <<< "$ORG_IDS"
for job in `jobs -p`; do
        wait $job
done

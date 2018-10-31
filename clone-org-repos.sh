#!/bin/bash

curl -s -H "Authorization: token e80...66d" https://..../api/v3/orgs/[ORG_NAME]/repos | grep ssh_url | sed 's/"//g' | sed 's/,//g' | xargs -n 1 git clone

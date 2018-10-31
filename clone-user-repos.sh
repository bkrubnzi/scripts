#!/bin/bash

curl -s -H "Authorization: token e80...66d" https://.../api/v3/user/repos | grep ssh_url | grep 008 | awk '{print $2}' | sed 's/"//g' | sed 's/,//g' | xargs -n 1 git clone

#!/bin/bash

if [ -z "$SSH_AUTH_SOCK" ] ; then
   eval `ssh-agent -s`
   ssh-add [KEY]
fi
trap 'test -n "$SSH_AGENT_PID" && eval `/usr/bin/ssh-agent -k`' 0

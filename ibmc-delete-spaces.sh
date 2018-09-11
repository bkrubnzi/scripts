#!/bin/bash

SPACES=`bx cf spaces | tail -n +6`;while IFS= read -r space; do bx cf delete-space "$space" -f;done <<< "$SPACES"

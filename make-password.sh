#!/bin/bash

openssl rand -base64 32 | cut -c1-$1

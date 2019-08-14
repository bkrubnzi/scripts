#!/bin/bash

## Monitor incoming traffic on port 53 ##
sudo tcpdump -s0 -lvni any 'udp port 53'

### Turn off dnsmasq ###
systemctl stop dnsmasq
systemctl disable dnsmasq
systemctl daemon-reload
### ---------------- ###

## Start up the container ##
docker run -v /home/**/dns-crypt-config/zones:/opt/unbound/etc/unbound/zones --ulimit nofile=90000:90000 --name=dnscrypt-server --net=host jedisct1/dnscrypt-server init -N example.net -E 172.16.*.*:443
docker start dnscrypt-server
## --------------------- ##

### Put the following lines in dnscrypt-proxy.toml ###
# server_names = ['example.net']
# listen_addresses = ['0.0.0.0:53'] 
# ...
# [static]
#
#   [static.'example.net']
#   stamp = 'sdns://AQc***5ldA'
### --------------------------------------------- ###

### Install the proxy service ###
/opt/dnscrypt-proxy/dnscrypt-proxy -service install
/opt/dnscrypt-proxy/dnscrypt-proxy -service start
### ------------------------  ###



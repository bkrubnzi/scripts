#!/bin/bash

## Monitor incoming traffic on port 53 ##
sudo tcpdump -s0 -lvni any 'udp port 53' | grep -E -o "(([a-zA-Z](-?[a-zA-Z0-9])*)\.)+[a-zA-Z]{2,}"

### Turn off dnsmasq ###
systemctl stop dnsmasq
systemctl disable dnsmasq
systemctl daemon-reload
### ---------------- ###

## Start up the container ##
docker run -v /home/**/dns-crypt-config/zones:/opt/unbound/etc/unbound/zones \
           -v /home/**/keys:/opt/encrypted-dns/etc/keys \
           --ulimit nofile=90000:90000 \
           --name=dnscrypt-server \
           --net=host jedisct1/dnscrypt-server init -N example.net -E 172.16.*.*:443
docker start dnscrypt-server
docker update --restart=unless-stopped dnscrypt-server
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

### Configure your firewall ###
firewall-cmd --list-all
firewall-cmd --permanent --add-service=dns
firewall-cmd --add-port=53/tcp
firewall-cmd --add-port=53/udp
firewall-cmd --reload
### ----------------------- ###


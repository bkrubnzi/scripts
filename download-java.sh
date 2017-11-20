#!/bin/bash

ansible all -i "127.0.0.1," -m get_url -a "url=http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz headers=\"Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie\" dest=/tmp/jdk-8u131-linux-x64.tar.gz" --key ~/.ssh/ansible.pem

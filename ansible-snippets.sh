#Quick insight into the host
ansible all -i "localhost," -m "debug" -a "var=hostvars[inventory_hostname]" -b
#look for some files
ansible all -i "localhost," -m "find" -a "path=/var/ossec/logs/ patterns='*.gz'" -b
#concatenate a list into a string
set_fact: ips=" {{instances.ip | join(',') }} "

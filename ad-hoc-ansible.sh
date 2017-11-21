#Quick insight into the host
ansible all -i "localhost," -m "debug" -a "var=hostvars[inventory_hostname]" -b

#Quick insight into the host
ansible all -i "localhost," -m "debug" -a "var=hostvars[inventory_hostname]" -b
#look for some files
ansible all -i "localhost," -m "find" -a "path=/var/ossec/logs/ patterns='*.gz'" -b
#concatenate a list into a string
  - set_fact: 
      volume_list=" {{target_volumes.id | join(',') }}"
#concatenate a set of strings into a list
  - set_fact:
      target_volumes: []
  - set_fact:
      target_volumes: "[ '{{ item.1.id }}' ] + {{ target_volumes }}"
    with_subelements:
      - "{{ log_volumes.results }}"
      - volumes

!#/bin/bash

lsblk
fdisk /dev/sda
  print
  n
  p
  default
  default
  w
reboot
pvcreate /dev/sda3
vgextend centos_2019 /dev/sda3
lvextend /dev/centos_2019/root /dev/sda3
xfs_growfs /dev/centos_2019/root

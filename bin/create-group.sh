#!/bin/bash

# usage: # create_group.sh conf/hosts informatika 1001
# to create a new group named 'informatika' with gid '1001' on all node listed in conf/hosts

test $# -lt 2 && { echo >&2 "Usage: $0 HOSTLIST GROUP [GID]" ; exit 1 ; }

#set -x

hosts=$1
group=$2
gid=$3

LOGFILE=log/create-group/$group.txt

test "x$gid" != "x" && gid="-g $gid"

groupadd $gid $group > >(tee ${LOGFILE}) 2>&1

for host in `cat $hosts`
do
  grep $group /etc/group | ssh $host 'cat >> /etc/group'
  ssh $host "hostname" > >(tee -a ${LOGFILE}) 2>&1
done

echo new group $group with $gid is created.

#EOF

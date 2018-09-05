#!/bin/bash

# usage: # delete_user.sh conf/hosts iamgroot
# to delete a user named 'iamgroot' on all node listed in conf/hosts

test $# -lt 2 && { echo >&2 "Usage: $0 HOSTLIST USER " ; exit 1 ; }

#set -x

# assign arguments as variables
hosts=$1
user=$2

# check if admin assign a specified uid
test "x$uid" != "x" && uid="-u $uid"

# delete the user on master node
userdel -r $user

# delete the user on listed nodes
for host in `cat $hosts`
do
   ssh $host "userdel -r $user"
done

# inform new user and her initial password
echo $user has been deleted.
#EOF

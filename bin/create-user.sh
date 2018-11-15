#!/bin/bash

# usage: # create_user.sh conf/hosts iamgroot 1001 1101
# to create a new user named 'iamgroot' on groupid '1001' with uid '1101'
# on all node listed in conf/hosts

test $# -lt 3 && { echo >&2 "Usage: $0 HOSTLIST USER EMAIL GID [UID]" ; exit 1 ; }

#set -x

# assign arguments as variables
hosts=$1
user=$2
email=$3
group=$4
uid=$5
login_node=[LOGINNODE]

LOGFILE=log/create-user/$user.txt

# check if admin assign a specified uid
test "x$uid" != "x" && uid="-u $uid"

# create/add user on master node
useradd -e `date -d "90 days" +"%Y-%m-%d"` $uid -g $group -c $email -m $user > >(tee -a ${LOGFILE}) 2>&1

# add user to slurm group
usermod -a -G slurm $user
usermod -a -G hadoop $user

# generate initiate password
passwd=`tr -dc A-Za-z0-9_ < /dev/urandom | head -c8`

# assign the initial password to the new user
echo "$user:$passwd" | chpasswd

# check if the new user is successfully created
userCreated=false

getent passwd $user > /dev/null &&userCreated=true

if $userCreated; then
   # propagate the new user to listed hosts
   for host in `cat $hosts`
   do
      for f in passwd shadow
      do
         line=`grep $user /etc/$f`
         printf -v sendLine %q "$line"
         ssh $host "echo $sendLine >> /etc/$f; usermod -a -G slurm $user; usermod -a -G hadoop $user"
      done
      ssh $host "hostname" > >(tee -a ${LOGFILE}) 2>&1
   done

   ssh ulin01 "su hdfs -c \"hdfs dfs -mkdir -p /user/$user; hdfs dfs -chown $user:$group /user/$user\""

#   for f in passwd shadow
#   do
#      line=`grep $user /etc/$f`
#      printf -v sendLine %q "$line"
#      for host in `cat $hosts`
#      do
#         ssh $host "echo $sendLine >> /etc/$f"
#      done
#   done

   # generate ssh-key for the new user
   ssh-keygen -t rsa -f ~/.ssh/$passwd -N "" &> /dev/null
   mkdir /home/$user/.ssh
   mv ~/.ssh/$passwd* /home/$user/.ssh/.
   rename "$passwd" "id_rsa" /home/$user/.ssh/$passwd*

   # passwordless ssh
   cp /home/$user/.ssh/id_rsa.pub /home/$user/.ssh/authorized_keys

   # collect workernodes' fingerprints
   for host in `cat $hosts`
   do
      ssh-keyscan -t rsa $host >> /home/$user/.ssh/known_hosts
   done

   # clean up, change all files ownership
   chown $user:$group -R /home/$user/.ssh

   # force user change password on login node on its first login
   ssh $login_node "chage -d 0 $user" > >(tee -a ${LOGFILE}) 2>&1

   # inform new user and her initial password
   echo $user : $email with $passwd is created > >(tee -a ${LOGFILE}) 2>&1
   # send email to user
      # send email to user
   printf "Welcome to grid.lipi.go.id.
A user has been created with
   username = $user
   password = $passwd
Please refer to http://grid.lipi.go.id/main/navigate/info_usage_grid for the user guide." | mail -s "Welcome to grid.lipi.go.id" -r grid@mail.lipi.go.id -c grid@mail.lipi.go.id $email
else
   # inform that no user is created
   echo $user is not created.
   echo >&2 "Usage: $0 HOSTLIST USER EMAIL GID [UID]" ; exit 1 ;
fi
#EOF

#!/bin/bash -e

source /root/.hpc-lipi

LOGDIR=/root/log

IFS=',' read -r -a NONGPU_WORKERS_ARR <<< ${NONGPU_WORKERS}
IFS=',' read -r -a GPU_WORKERS_ARR <<< ${GPU_WORKERS}

#HOSTS_ARR=( "${NONGPU_WORKERS_ARR[@]}" "${GPU_WORKERS_ARR[@]}" "${BATCH_SERVER}" "${APPS_SERVER}" )

HOST_ARR+=( "${NONGPU_WORKERS_ARR[@]}" )
HOST_ARR+=( "${GPU_WORKERS_ARR[@]}" )
HOST_ARR+=( "${BATCH_SERVER}" "${APPS_SERVER}" )

test $# -lt 3 && { echo >&2 "Usage: $0 [CPU | GPU] USER EMAIL" ; exit 1 ; }

user=$2
email=$3
name=$4
uid=$NEW_UID
#gid=$GROUPID
#cgid=$CPUGROUPID
#ggid=$GPUGROUPID

if [ $1 == "CPU" ]
   then
      gid=$CPUGROUPID
elif [ $1 == "GPU" ]
   then
      gid=$GPUGROUPID
fi

LOGFILE=$LOGDIR/$user.log

# check all hosts are avaiable
echo "Checking up the engine.."
for HOST in ${HOST_ARR[@]}
do
#	echo ${HOST}
        ssh ${HOST} "hostname"
        if [ "$?" -ne "0" ]
        then
                echo "${HOST} is not available. Please check the node status."
		exit 1
        fi
done
echo "Great! All engine looks good."
# create user on the main node.

test "x$uid" != "x" && uid="-u $uid"

echo "creating USER = ${user} on SUBMITTER = ${SUBMITTER}" > >(tee ${LOGFILE}) 2>&1
useradd -e `date -d "90 days" +"%Y-%m-%d"` ${uid} -g ${gid} -c ${email} -m ${user} > >(tee -a ${LOGFILE}) 2>&1

# generate initiate password
passwd=`tr -dc A-Za-z0-9_ < /dev/urandom | head -c8`

# assign the initial password to the new user
echo "$user:$passwd" | chpasswd

# force user to change password on the first login
#chage -d 0 $user > >(tee -a ${LOGFILE}) 2>&1

# check if the new user is successfully created
userCreated=false

getent passwd $user > /dev/null &&userCreated=true

## user is created on submitter

if $userCreated; then
	# propagate the new user
	echo "creating USER=${user} on BATCH_SERVER = ${BATCH_SERVER}" > >(tee ${LOGFILE}) 2>&1
	for f in  passwd shadow
	do
		grep ${user} /etc/${f} | ssh ${BATCH_SERVER} "cat >> /etc/${f}"
	done
	ssh ${BATCH_SERVER} "hostname" > >(tee -a ${LOGFILE}) 2>&1

	echo "creating USER=${user} on APPS_SERVER = ${APPS_SERVER}" > >(tee ${LOGFILE}) 2>&1
	for f in  passwd shadow
	do
		grep ${user} /etc/${f} | ssh ${APPS_SERVER} "cat >> /etc/${f}"
	done
	ssh ${APPS_SERVER} "hostname" > >(tee -a ${LOGFILE}) 2>&1

	echo "creating USER=${user} on NONGPU_WORKERS = ${NONGPU_WORKERS}" > >(tee ${LOGFILE}) 2>&1
	for NONGPU_WORKER in ${NONGPU_WORKERS_ARR[@]}
	do
		for f in  passwd shadow
		do
			grep ${user} /etc/${f} | ssh ${NONGPU_WORKER} "cat >> /etc/${f}"
			ssh ${NONGPU_WORKER} "hostname" > >(tee -a ${LOGFILE}) 2>&1
		done
	done

	echo "creating USER=${user} on GPU_WORKERS = ${GPU_WORKERS}" > >(tee ${LOGFILE}) 2>&1
	for GPU_WORKER in ${GPU_WORKERS_ARR[@]}
	do
		for f in  passwd shadow
		do
			grep ${user} /etc/${f} | ssh ${GPU_WORKER} "cat >> /etc/${f}"
			ssh ${GPU_WORKER} "hostname" > >(tee -a ${LOGFILE}) 2>&1
		done
	done

	# generate ssh-key for the new user
   	ssh-keygen -t rsa -f ~/.ssh/${passwd} -N "" &> /dev/null
   	mkdir /home/${user}/.ssh
   	mv ~/.ssh/${passwd}* /home/${user}/.ssh/.
	rename "${passwd}" "id_rsa" /home/${user}/.ssh/${passwd}*

	# passwordless ssh
   	cp /home/${user}/.ssh/id_rsa.pub /home/${user}/.ssh/authorized_keys

   	# collect workernodes' fingerprints <=== check
   	for host in ${HOSTS_ARR[@]}
   	do
      		ssh-keyscan -t rsa ${host} >> /home/${user}/.ssh/known_hosts
   	done

	# clean up, change all files ownership
   	chown ${user}:${gid} -R /home/${user}/.ssh


        # force user to change password on the first login
        chage -d 0 $user > >(tee -a ${LOGFILE}) 2>&1

	# inform new user and her initial password
   	echo ${user} : ${email} with ${passwd} is created > >(tee -a ${LOGFILE}) 2>&1
   	# send email to user
      	# send email to user
   	printf "Welcome to Mahameru HPC - Supercomputing Service By LIPI.
A user has been created with
   username = ${user}
   password = ${passwd}
Please refer to https://hpc.lipi.go.id/manual-usage/ for the user guide." | mail -s "Welcome to Mahameru HPC" -r grid@mail.lipi.go.id -c grid@mail.lipi.go.id ${email}
else
   # inform that no user is created
   echo ${user} is not created.
   echo >&2 "Usage: $0 USER EMAIL" ; exit 1 ;
fi

echo "UID = ${NEW_UID}"
OLD_UID=${NEW_UID}
NEW_UID=$((NEW_UID + 1))
sed -i "s/NEW_UID=${OLD_UID}/NEW_UID=${NEW_UID}/g" /root/.hpc-lipi

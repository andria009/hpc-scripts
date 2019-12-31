#!/bin/bash -e

source /root/.hpc-lipi

LOGDIR=/root/log

IFS=',' read -r -a NONGPU_WORKERS_ARR <<< ${NONGPU_WORKERS}
IFS=',' read -r -a GPU_WORKERS_ARR <<< ${GPU_WORKERS}

HOSTS_ARR=( "${NONGPU_WORKERS_ARR[@]}" "${GPU_WORKERS_ARR[@]}" "${BATCH_SERVER}" "${APPS_SERVER}" )

test $# -lt 1 && { echo >&2 "Usage: $0 USER" ; exit 1 ; }

user=$1
email=$2
name=$3
uid=$NEW_UID
gid=$GROUPID

LOGFILE=$LOGDIR/$user.del

test "x$uid" != "x" && uid="-u $uid"

echo "delete USER = ${user} on SUBMITTER = ${SUBMITTER}" > >(tee ${LOGFILE}) 2>&1
#userdel -r ${user} > > (tee -a ${LOGFILE}) 2>&1
userdel -r ${user}

echo "deleting USER=${user} on BATCH_SERVER = ${BATCH_SERVER}" > >(tee ${LOGFILE}) 2>&1
ssh ${BATCH_SERVER} "hostname" > >(tee -a ${LOGFILE}) 2>&1
ssh ${BATCH_SERVER} "userdel -r ${user}" 

echo "deleting USER=${user} on APPS_SERVER = ${APPS_SERVER}" > >(tee ${LOGFILE}) 2>&1
ssh ${APPS_SERVER} "hostname" > >(tee -a ${LOGFILE}) 2>&1
ssh ${APPS_SERVER} "userdel -r ${user}" 

echo "deleting USER=${user} on NONGPU_WORKERS = ${NONGPU_WORKERS}" > >(tee ${LOGFILE}) 2>&1
for NONGPU_WORKER in ${NONGPU_WORKERS_ARR[@]}
do
	ssh ${NONGPU_WORKER} "hostname" > >(tee -a ${LOGFILE}) 2>&1
	ssh ${NONGPU_WORKER} "userdel -r ${user}"
done

echo "deleting USER=${user} on GPU_WORKERS = ${GPU_WORKERS}" > >(tee ${LOGFILE}) 2>&1
for GPU_WORKER in ${GPU_WORKERS_ARR[@]}
do
	ssh ${GPU_WORKER} "hostname" > >(tee -a ${LOGFILE}) 2>&1
	ssh ${GPU_WORKER} "userdel -r ${user}"
done

# inform new user and her initial password
echo ${user} is deleted > >(tee -a ${LOGFILE}) 2>&1

# send email to user
   	printf "User deletion to grid.lipi.go.id.
A user has been deleted with
   username = ${user}
Please refer to http://grid.lipi.go.id/main/navigate/info_usage_grid for the user guide." | mail -s "Welcome to grid.lipi.go.id" -r grid@mail.lipi.go.id grid@mail.lipi.go.id

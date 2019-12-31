#!/bin/bash -e

source /root/.hpc-lipi

LOGDIR=/root/log

IFS=',' read -r -a NONGPU_WORKERS_ARR <<< ${NONGPU_WORKERS}
IFS=',' read -r -a GPU_WORKERS_ARR <<< ${GPU_WORKERS}

test $# -lt 2 && { echo >&2 "Usage: $0 GROUP [GID]" ; exit 1 ; }

group=$1
gid=$2

LOGFILE=$LOGDIR/$group.log

test "x$gid" != "x" && gid="-g $gid"

echo "creating group on SUBMITTER = ${SUBMITTER}" > >(tee ${LOGFILE}) 2>&1
groupadd $gid $group > >(tee ${LOGFILE}) 2>&1

echo "creating group on BATCH_SERVER = ${BATCH_SERVER}" > >(tee ${LOGFILE}) 2>&1
grep $group /etc/group | ssh ${BATCH_SERVER} 'cat >> /etc/group'
ssh ${BATCH_SERVER} "hostname" > >(tee -a ${LOGFILE}) 2>&1

echo "creating group on APPS_SERVER = ${APPS_SERVER}" > >(tee ${LOGFILE}) 2>&1
grep $group /etc/group | ssh ${APPS_SERVER} 'cat >> /etc/group'
ssh ${APPS_SERVER} "hostname" > >(tee -a ${LOGFILE}) 2>&1

echo "creating group on NONGPU_WORKERS = ${NONGPU_WORKERS}" > >(tee ${LOGFILE}) 2>&1
for NONGPU_WORKER in ${NONGPU_WORKERS_ARR[@]}
do
  grep $group /etc/group | ssh ${NONGPU_WORKER} 'cat >> /etc/group'
  ssh ${NONGPU_WORKER} "hostname" > >(tee -a ${LOGFILE}) 2>&1
done

echo "creating group on GPU_WORKERS = ${GPU_WORKERS}" > >(tee ${LOGFILE}) 2>&1
for GPU_WORKER in ${GPU_WORKERS_ARR[@]}
do
  grep $group /etc/group | ssh ${GPU_WORKER} 'cat >> /etc/group'
  ssh ${GPU_WORKER} "hostname" > >(tee -a ${LOGFILE}) 2>&1
done

echo new group $group with $gid is created.

#EOF

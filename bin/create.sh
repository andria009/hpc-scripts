#!/bin/bash -e

source /root/.hpc-lipi

LOGDIR=/root/log

IFS=',' read -r -a NONGPU_WORKERS_ARR <<< ${NONGPU_WORKERS}
IFS=',' read -r -a GPU_WORKERS_ARR <<< ${GPU_WORKERS}

#for GPU_WORKER in ${GPU_WORKERS_ARR[@]}; do
#	echo $GPU_WORKER
#done

#for NONGPU_WORKER in ${NONGPU_WORKERS_ARR[@]}; do
#	echo $NONGPU_WORKER
#done

HOSTS=( "${NONGPU_WORKERS_ARR[@]}" "${GPU_WORKERS_ARR[@]}" "${BATCH_SERVER}" "${APPS_SERVER}" )
for HOST in ${HOSTS[@]}; do
	echo $HOST
done

#echo "UID = ${NEW_UID}"
#OLD_UID=${NEW_UID}
#NEW_UID=$((NEW_UID + 1))
#echo "OLD_UID = ${OLD_UID}"
#echo "NEW_UID = ${NEW_UID}"
#sed -i "s/NEW_UID=${OLD_UID}/NEW_UID=${NEW_UID}/g" /root/.hpc-lipi

user_count=${USER_COUNT}
next_user_count=$((user_count + 1))
prefix="lgr057"

printf -v user_seq "%04d" ${next_user_count}
next_userid=${prefix}${user_seq}
user_count=$((user_count + 1))

echo $next_userid
echo $user_count

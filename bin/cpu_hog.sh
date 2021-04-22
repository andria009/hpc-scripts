#!/bin/bash

while true
do
	sleep 60
	USAGE=`ps -eo pcpu,pid -o comm= | sort -k1 -n -r | head -1 | awk '{ print $1 } '`
	USAGE=${USAGE%.*}
	PID=`ps -eo pcpu,pid -o comm= | sort -k1 -n -r | head -1 | awk '{print $2 }'`
	PNAME=`ps -eo pcpu,pid -o comm= | sort -k1 -n -r | head -1 | awk '{print $3 }'`

	if [ $USAGE -gt 80 ] 
	then
		USAGE1=$USAGE
		PID1=$PID
		PNAME1=$PNAME
		sleep 60
		USAGE2=`ps -eo pcpu,pid -o comm= | sort -k1 -n -r | head -1 | awk '{ print $1 } '`
		USAGE2=${USAGE2%.*}
		PID2=`ps -eo pcpu,pid -o comm= | sort -k1 -n -r | head -1 | awk '{print $2 }'`
		PNAME2=`ps -eo pcpu,pid -o comm= | sort -k1 -n -r | head -1 | awk '{print $3 }'`
		HOST=`hostname -s`
		UNAME=`ps -eo pcpu,pid,euser,uid | grep ${PID1} | awk '{print $3}'`
		EMAIL=`grep ${UNAME} /etc/passwd | awk -F: '{print $5}'`

		if [ $USAGE2 -gt 80 ] && [ $PID1 = $PID2 ]
		then
			kill -15 $PID1
			echo "${PNAME1} with ${PID1} that belongs to ${UNAME} (${EMAIL}) is hogging CPU. It is killed"
			#echo "${PNAME1} with ${PID1} is hogging CPU. It is killed"
			printf "${PNAME1} with ${PID1} that belongs to ${UNAME} (${EMAIL}) is hogging CPU. It is killed" | mail -s "CPU @${HOST} load of ${PNAME1} is above 80% and be killed" -r grid@mail.lipi.go.id -c grid@mail.lipi.go.id ${EMAIL}
			#printf "${PNAME1} with ${PID1} is hogging CPU. It is killed" | mail -s "CPU @${HOST} load of ${PNAME1} is above 80% and be killed" grid@mail.lipi.go.id
		fi
	fi
done

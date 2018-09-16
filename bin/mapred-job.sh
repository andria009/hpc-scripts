#!/bin/bash

key="$1"
case $key in
    -list)
    	ssh ulin01 "mapred job -list all"
    	;;
    -history)
	ssh ulin01 "mapred job -history all"
    	;;
    -history_id)
    	jobid="$2"
    	ssh ulin01 "mapred job -history all $jobid"
    	;;
    -status)
    	jobid="$2"
    	ssh ulin01 "mapred job -status $jobid"
    	;;
    *)    # unknown option
    	echo "usage:"
	echo "mapred-job -list"
	echo "mapred-job -history"
	echo "mapred-job -history_id [jobId]"
	echo "mapred-job -status [jobId]"
    	;;
esac

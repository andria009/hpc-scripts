#!/bin/bash

key="$1"
case $key in
    -copyFromLocal)
    input="$2"
    output="$3"
    ssh ulin01 "hdfs dfs -copyFromLocal $input $output"
    ;;
    -copyToLocal)
    input="$2"
    output="$3"
    ssh ulin01 "hdfs dfs -copyToLocal $input $output"
    ;;
    -ls)
    path=$2
    ssh ulin01 "hdfs dfs -ls $path"
    ;;
    -rmr)
    path=$2
    ssh ulin01 "hdfs dfs -rm -r $path"
    ;;
    *)    # unknown option
    echo "usage:"
    echo "hadoop-dfs -copyFromLocal [input] [output]"
    echo "hadoop-dfs -copyToLocal [input] [output]"
    echo "hadoop-dfs -ls [path]"
    echo "hadoop-dfs -rmr [path]"
    ;;
esac

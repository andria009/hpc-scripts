#!/bin/bash

key="$1"
case $key in
    -cat)
    	hdfsFile="$2"
    	ssh ulin01 "hdfs dfs -cat $hdfsFile"
    	;;
    -append)
    	localFile="$2"
	hdfsFile="$3"
	ssh ulin01 "hdfs dfs -appendToFile $localFile $hdfsFile"
    	;;
    -copyFromLocal)
    	localFile="$2"
    	hdfsFile="$3"
    	ssh ulin01 "hdfs dfs -copyFromLocal $localFile $hdfsFile"
    	;;
    -copyToLocal)
    	hdfsFile="$2"
    	localFile="$3"
    	ssh ulin01 "hdfs dfs -copyToLocal $hdfsFile $localFile"
    	;;
    -ls)
    	hdfsPath="$2"
    	ssh ulin01 "hdfs dfs -ls $hdfsPath"
    	;;
    -cp)
	srcHdfsFile="$2"
	dstHdfsFile="$3"
	ssh ulin01 "hdfs dfs -cp $srcHdfsFile $dstHdfsFile"
    -cpp)
	srcHdfsFile="$2"
	dstHdfsFile="$3"
	ssh ulin01 "hdfs dfs -cp -p $srcHdfsFile $dstHdfsFile"
    -cpf)
	srcHdfsFile="$2"
	dstHdfsFile="$3"
	ssh ulin01 "hdfs dfs -cp -f $srcHdfsFile $dstHdfsFile"
    -rmr)
    	hdfsPath="$2"
    	ssh ulin01 "hdfs dfs -rm -r $hdfsPath"
    	;;
    *)    # unknown option
    	echo "usage:"
    	echo "hadoop-dfs -cat [hdfsFile]"
    	echo "hadoop-dfs -append [localFile] [hdfsFile]"
    	echo "hadoop-dfs -copyFromLocal [localFile] [hdfsFile]"
    	echo "hadoop-dfs -copyToLocal [hdfsFile [localFile]"
    	echo "hadoop-dfs -ls [hdfsPath]"
	echo "hadoop-dfs -cp [srcHdfsFile] [dstHdfsFile]"
	echo "hadoop-dfs -cpp [srcHdfsFile] [dstHdfsFile]"
	echo "hadoop-dfs -cpf [srcHdfsFile] [dstHdfsFile]"
    	echo "hadoop-dfs -rmr [hdfsPath]"
    ;;
esac

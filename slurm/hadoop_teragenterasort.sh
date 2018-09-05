#!/bin/bash
#
#SBATCH --job-name=teragen_terasort
#SBATCH --output=teragen_terasort.out
#SBATCH --error=teragen_terasort.err
#
#SBATCH --ntasks=1
#SBATCH --time=10:00
#
#SBATCH --partition=bigdata

hadoop jar /usr/hdp/current/hadoop-mapreduce-client/hadoop-mapreduce-examples-3.1.0.3.0.0.0-1634.jar teragen 10000 tmp/teragenout
hadoop jar /usr/hdp/current/hadoop-mapreduce-client/hadoop-mapreduce-examples-3.1.0.3.0.0.0-1634.jar terasort tmp/teragenout tmp/terasortout

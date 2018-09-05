#!/bin/bash
#
#SBATCH --job-name=hellompich
#SBATCH --output=hellompich-1.out
#
#SBATCH --ntasks=64
#SBATCH --time=10:00
#
#SBATCH --partition=public

module load mpich/3.2.1
srun hello.mpich

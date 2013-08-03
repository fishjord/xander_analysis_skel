#!/bin/bash

## qsub -l walltime=hh:mm:ss,mem=60000mb -v targets=all,workdir=`pwd` path/to/make_wrapper.sh 

module load HMMER/3.0
module load bowtie/2.2.1
module load CDHIT/4.6.1b
module load SAMTools/0.1.12a

cd $workdir
make $targets
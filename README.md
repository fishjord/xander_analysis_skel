# Xander skeleton analysis pipeline

## Setup
### Quickstart

Edit Makefile variable NAME to a name to identify the analysis and SEQFILE to be the absolute path to the input sequence reads, then type:

```bash
make setup && make
```

This will configure a python virtual environment, clone a utility scripts git repository, and start the anaylsis (sequentially).  Since many portions of the analysis pipeline are parallelizable, and can take large amounts of memory a recommended workflow of make targets is listed in the Analysis section below.

### Required tools

* GNU Make
* Python 2.7+
    * numpy 1.6+
    * matplotlib 1.2+
    * biopython
    * argparse
* Java 1.6+
* HMMER 3.0 (If using 3.1+ remove --allcol from gene.Makefile)
* Samtools 0.1.12+
* CDHit 4.6.1+
* Git (only required to clone the glowing_sakana repository)
* Bowtie2 (Only required for coverage analysis)
* Weblogo3 (Only required for primer analysis)

### Initial Setup

The quick way to setup the analysis pipeline is to run

```bash

make setup
```

This will create a python virtual environment (using python 2.7) in the analysis directory as py_virtenv and install numpy, biopython and matplotlib as well as clone the glowing_sakana repository from https://github.com/fishjord/glowing_sakana which contains many Bioinformatics utility scripts.  

If you already have a python virtual environment setup or have glowing_sakana cloned you can change the GLOWING_SAKANA and PYTHON_VIRTENV variables in the Makefile to point to the appropriate directories.

## Gene Analysis Directories

Reference sequence files and models for each gene targeted for assembly are placed in a directory in the main analysis directory.  Included with the skeleton analysis pipeline are configurations for assembling rplB, nirK, and nifH genes.

A gene analysis directory must contain two hidden markov models built with HMMER3 named for_enone.hmm and rev_enone.hmm for the forward and reverse of the gene sequences respectively.  Also a ref_aligned.faa file must contain a set of protein reference sequences aligned with for_enone.hmm.  This file is used to identify starting kmers for assembly.

The analysis pipeline will attempt to assemble all genes specified in the Makefile variable 'genes' (see below), which requires a directory for each gene name with the above structure.  See the existing rplb/nirk/nifh directories for further examples.

## Analysis

### Suggested Workflow

While you can type 
```bash
make setup && make
```

some steps steps can be run in parallel as suggested below

1. 
    a. Building the bloom filter (once per dataset)
```bash
	make bloom
```

    b. Identify assembly starting kmers (can be done in parallel with bloom filter generation), this step will use up to THREAD threads
```bash
	make filtered_starts.txt
```

2. Assemble each gene (each gene can be done in parallel)
```bash
make <gene_name>
```

3. Bowtie and K-mer mapping (In progress)
```
make bowtie
```

### Running on the MSU (or similar) High Performance Computing Cluster
Included in the analysis pipeline is a script that can be submitted to job control systems (tested with qsub on the MSU HPCC) in bin/make_wrapper.sh, below are commands for the steps listed above to submit each task to a cluster instead

1. Bloom filter & assembly starts
    a. 
```bash
qsub -l walltime=24:00:00,mem=<MAX_MEM>mb -v workdir=`pwd`,targets=bloom bin/make_wrapper.sh
```

    b.
```bash
qsub -l walltime=08:00:00,mem=4000mb,nodes=1:ppn=<THREADS> -v workdir=`pwd`,targets=filtered_starts.txt bin/make_wrapper.sh
```

2.  Assemble each gene (each gene can be done in parallel)
```bash
qsub -l walltime=08:00:00,mem=4000mb,nodes=1:ppn=4 -v workdir=`pwd`,targets=<gene_name> bin/make_wrapper.sh
```

3. Bowtie and K-mer mapping (In progress)
```bash
qsub -l walltime=08:00:00,mem=4000mb,nodes=1:ppn=4 -v workdir=`pwd`,targets=bowtie bin/make_wrapper.sh
```

## Makefile Parameters

### Analysis Parameters
* NAME -- Name of the analysis, used to prefix (most) generated files
* SEQFILE -- Absolute path to the sequence file (_MUST_ be the absolute path)
* genes -- Genes to assemble (supported out of the box: rplB, nirK, nifH), see Gene Directories
* THREADS -- number of threads to use

### DBG Parameters
* MAX_JVM_HEAP -- Maximum amount of memory DBG processes can use (must be larger than FILTER_SIZE below)
* K_SIZE -- K-mer size to assemble at, must be divisible by 3 (recommended below 32, but can be as high as 63)
* FILTER_SIZE -- Size of the bloom filter log2: 38 = 32 gigs, 37 = 16 gigs, 36 = 8 gigs, 35 = 4 gigs

### Contig Filtering Parameters
* MIN_LENGTH -- Minimum length of a merged contig
* MIN_BITS -- Minimum bits saved of a merged contig

### Coverage Filtering
* MIN_MEDIAN_COV -- Minimum median coverage after mapping
* MIN_MAPPED_RATIO -- Minimum ratio 

### Program Paths (Can be program names if they are on your path)
* BOWTIE
* SAMTOOLS
* CDHIT
* HMMALIGN 
* WEBLOGO

### Other Paths
* JAR_DIR -- Path to jar files for Xander/ReadSeq/ProbeMatch/KmerFilter (included in repository)
* GLOWING_SAKANA -- Path to glowing sakana, included as a git submodule but can be changed to point to another clone of the repository
* PYTHON_VIRTENV -- Path to a virtual environment with at least biopython, matplotlib, and numpy installed
* GENE_MAKEFILE -- Gene makefile, don't change
* BLOOM -- Name of the bloom filter (used by submake files)

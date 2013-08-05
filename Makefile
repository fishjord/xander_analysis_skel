NAME= iowa_prairie
SEQFILE= /mnt/lustre_scratch_2012/gjr/data/gpgc/SEQ.fa
genes= nirk rplb nifh

MAX_JVM_HEAP= 48G
K_SIZE= 30
FILTER_SIZE= 38 # 2**FILTER_SIZE, 38 = 32 gigs, 37 = 16 gigs, 36 = 8 gigs, 35 = 4 gigs

MIN_LENGTH= 150  # in nucleotides
MIN_MEDIAN_COV= 3
MIN_MAPPED_RATIO= 1 #Ratio of the contig that must have reads mapped to it

ASSEMBLY_FILE= all_contigs.fasta

BOWTIE= bowtie2
SAMTOOLS= samtools
CDHIT= cd-hit

JAR_DIR=$(realpath jars)
GLOWING_SAKANA=$(realpath glowing_sakana)
PYTHON_VIRTENV=$(realpath py_virtenv)
GENE_MAKEFILE=$(realpath gene.Makefile)
BLOOM= $(realpath $(NAME).bloom)
HMMALIGN= hmmalign
WEBLOGO= /home/fishjord/apps/weblogo-3.3/weblogo

export

all: $(genes) all_contigs cdhit bowtie

.PHONY: $(genes) clean setup veryclean bowtie cdhit

bloom: $(NAME).bloom

$(NAME).bloom: $(SEQFILE)
	java -Xmx$(MAX_JVM_HEAP) -jar $(JAR_DIR)/hmmgs.jar build $(SEQFILE) $(NAME).bloom $(K_SIZE) $(FILTER_SIZE)

%/gene_starts.txt: filtered_starts.txt
	grep $* filtered_starts.txt > $*/gene_starts.txt

.SECONDEXPANSION:

$(genes): bloom $$@/gene_starts.txt
	$(MAKE) -C $@ --makefile=$(GENE_MAKEFILE)

filtered_starts.txt: starts.txt
	(. $(PYTHON_VIRTENV)/bin/activate;$(GLOWING_SAKANA)/hmmgs/filter_starts.py starts.txt > filtered_starts.txt) || (rm filtered_starts.txt && false)

starts.txt: $(SEQFILE)
	(java -Xmx2g  -jar $(JAR_DIR)/KmerFilter.jar fast_kmer_filter --threads=4 -a $(K_SIZE) -o starts.txt $(SEQFILE) $(foreach gene,$(genes),$(gene)=$(gene)/ref_aligned.faa)) || (rm starts.txt && false)

all_contigs: $(genes)
	$(MAKE) -C all_contigs

cdhit: all_contigs
	$(MAKE) -C cdhit

bowtie: cdhit
	$(MAKE) -C bowtie

clean:
	for gene in $(genes); do $(MAKE) -C $$gene --makefile=$(GENE_MAKEFILE) clean; done;
	- (rm *~ starts.txt filtered_starts.txt)
	cd cdhit && $(MAKE) clean
	cd all_contigs && $(MAKE) clean
	cd bowtie && $(MAKE) clean

very_clean: clean
	- (rm -rf $(NAME).bloom)

setup: glowing_sakana/.gitignore py_virtenv/bin/activate

glowing_sakana/.gitignore: 
	git submodule init && git submodule update

py_virtenv/bin/activate:
	virtualenv --no-site-packages --python python2.7 py_virtenv && source py_virtenv/bin/activate && pip install numpy && pip install matplotlib && pip install biopython

### UNUSED
trim: trimmed_reads.fasta

trimmed_reads.fasta:
	java -cp $(JAR_DIR)/ReadSeq.jar edu.msu.cme.rdp.readseq.utils.QualityTrimmer -i '#' $(SEQFILE)


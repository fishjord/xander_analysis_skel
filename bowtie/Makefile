BWT_PREFIX= $(NAME)_bwt

all: $(NAME)_final_seqs.fasta

$(BWT_PREFIX).1.bt2: ../cdhit/cdhit_$(ASSEMBLY_FILE)
	$(BOWTIE)-build ../cdhit/cdhit_$(ASSEMBLY_FILE) $(BWT_PREFIX)

$(NAME)_mapped_reads.bam: $(BWT_PREFIX).1.bt2
	($(BOWTIE) -f -x $(BWT_PREFIX) -U $(SEQFILE) | $(SAMTOOLS) view -S -F4 -b - > $(NAME)_mapped_reads.bam) || (rm $(NAME)_mapped_reads.bam && false)

$(NAME)_sorted_hits.bam: $(NAME)_mapped_reads.bam
	$(SAMTOOLS) sort $(NAME)_mapped_reads.bam $(NAME)_sorted_hits

$(NAME)_mapping_coverage_details.txt: $(NAME)_sorted_hits.bam
	($(SAMTOOLS) mpileup $(NAME)_sorted_hits.bam > $(NAME)_mapping_coverage_details.txt) || (rm $(NAME)_mapping_coverage_details.txt && false)

$(NAME)_mapping_coverage.txt: $(NAME)_mapping_coverage_details.txt ../cdhit/cdhit_$(ASSEMBLY_FILE)
	(source $(PYTHON_VIRTENV)/bin/activate && $(GLOWING_SAKANA)/misc/mpileup_ref_coverage.py --min-mapped-ratio $(MIN_MAPPED_RATIO) --min-median-cov $(MIN_MEDIAN_COV) --min-length $(MIN_LENGTH) $(NAME)_mapping_coverage_details.txt ../cdhit/cdhit_$(ASSEMBLY_FILE) > $(NAME)_mapping_coverage.txt) || (rm $(NAME)_mapping_coverage.txt && false)

$(NAME)_final_seqs.fasta: $(NAME)_mapping_coverage.txt ../cdhit/cdhit_$(ASSEMBLY_FILE)
	(source $(PYTHON_VIRTENV)/bin/activate && cut -f1 $(NAME)_mapping_coverage.txt | grep -v '#' > final_seqids.tmp && $(GLOWING_SAKANA)/seq_utils/find_seqs.py final_seqids.tmp keep ../cdhit/cdhit_$(ASSEMBLY_FILE) > $(NAME)_final_seqs.fasta && rm final_seqids.tmp) || (rm $(NAME)_final_seqs.fasta && false)

clean:
	-(rm *.bam *.fasta *.txt *.bt2)
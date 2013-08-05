BWT_PREFIX= $(NAME)_bwt
COMBINED_CONTIGS= combined_contigs.fasta

all: $(NAME)_final_seqs.fasta

$(COMBINED_CONTIGS):
	. $(PYTHON_VIRTENV)/bin/activate && \
        > $(COMBINED_CONTIGS) && \
        ($(foreach gene,$(genes),($(GLOWING_SAKANA)/seq_utils/rename_seqs.py ../$(gene)/nucl_cdhit.fasta $(gene) >> $(COMBINED_CONTIGS));)) || (rm $(COMBINED_CONTIGS) && false)

$(BWT_PREFIX).1.bt2: $(COMBINED_CONTIGS)
	$(BOWTIE)-build $(COMBINED_CONTIGS) $(BWT_PREFIX)

$(NAME)_mapped_reads.bam: $(BWT_PREFIX).1.bt2
	($(BOWTIE) -f -x $(BWT_PREFIX) -U $(SEQFILE) | $(SAMTOOLS) view -S -F4 -b - > $(NAME)_mapped_reads.bam) || (rm $(NAME)_mapped_reads.bam && false)

$(NAME)_sorted_hits.bam: $(NAME)_mapped_reads.bam
	$(SAMTOOLS) sort $(NAME)_mapped_reads.bam $(NAME)_sorted_hits

$(NAME)_mapping_coverage_details.txt: $(NAME)_sorted_hits.bam
	($(SAMTOOLS) mpileup $(NAME)_sorted_hits.bam > $(NAME)_mapping_coverage_details.txt) || (rm $(NAME)_mapping_coverage_details.txt && false)

$(NAME)_mapping_coverage.txt: $(NAME)_mapping_coverage_details.txt $(COMBINED_CONTIGS)
	(source $(PYTHON_VIRTENV)/bin/activate && $(GLOWING_SAKANA)/misc/mpileup_ref_coverage.py --min-mapped-ratio $(MIN_MAPPED_RATIO) --min-median-cov $(MIN_MEDIAN_COV) --min-length $(MIN_LENGTH) $(NAME)_mapping_coverage_details.txt $(COMBINED_CONTIGS) > $(NAME)_mapping_coverage.txt) || (rm $(NAME)_mapping_coverage.txt && false)

$(NAME)_final_seqs.fasta: $(NAME)_mapping_coverage.txt $(COMBINED_CONTIGS)
	(source $(PYTHON_VIRTENV)/bin/activate && cut -f1 $(NAME)_mapping_coverage.txt | grep -v '#' > final_seqids.tmp && $(GLOWING_SAKANA)/seq_utils/find_seqs.py final_seqids.tmp keep $(COMBINED_CONTIGS) > $(NAME)_final_seqs.fasta && rm final_seqids.tmp) || (rm $(NAME)_final_seqs.fasta && false)

clean:
	-(rm *.bam *.fasta *.txt *.bt2)
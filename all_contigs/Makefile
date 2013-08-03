all: $(ASSEMBLY_FILE) $(NAME)_read_kmer_coverage.txt unmerged.fasta

$(ASSEMBLY_FILE): 
	. $(PYTHON_VIRTENV)/bin/activate && \
	> $(ASSEMBLY_FILE) && \
	($(foreach gene,$(genes),($(GLOWING_SAKANA)/seq_utils/rename_seqs.py ../$(gene)/nucl_merged.fasta $(gene) >> $(ASSEMBLY_FILE));)) || (rm $(ASSEMBLY_FILE) && false)

unmerged.fasta:
	. $(PYTHON_VIRTENV)/bin/activate && \
	> unmerged.fasta && \
	($(foreach gene,$(genes),($(GLOWING_SAKANA)/seq_utils/rename_seqs.py ../$(gene)/gene_starts.txt_nucl.fasta $(gene) >> unmerged.fasta);)) || (rm unmerged.fasta && false)

$(NAME)_read_kmer_coverage.txt: $(ASSEMBLY_FILE)
	(java -Xmx2g -cp $(JAR_DIR)/hmmgs.jar edu.msu.cme.rdp.graph.abundance.ReadKmerMapper $(ASSEMBLY_FILE) $(SEQFILE) $(K_SIZE) 4 > $(NAME)_read_kmer_coverage.txt || (rm $(NAME)_read_kmer_coverage.txt && false))

clean:
	- (rm *.txt *.fasta)
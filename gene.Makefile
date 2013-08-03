hmmgs_result_prefix= gene_starts.txt

.PHONY: clean all

all: nucl_merged.fasta
	$(foreach sub,$(dir $(SUBMAKES)),cd $(sub) && $(MAKE);)

basic_hmmgs.txt: $(BLOOM)
	(java -Xmx$(MAX_JVM_HEAP) -jar $(JAR_DIR)/hmmgs.jar search 1 30 $(BLOOM) for_enone.hmm rev_enone.hmm $(hmmgs_result_prefix) > basic_hmmgs.txt 2> hmmgs.stderr) || (rm basic_hmmgs.txt && false)

nucl_merged.fasta: $(hmmgs_result_prefix)_nucl.fasta
	java -Xmx4g -jar $(JAR_DIR)/hmmgs.jar merge --min-bits 20 for_enone.hmm basic_hmmgs.txt $(hmmgs_result_prefix)_nucl.fasta &> merge_stats.txt

$(hmmgs_result_prefix)_prot.fasta: basic_hmmgs.txt
$(hmmgs_result_prefix)_nucl.fasta: basic_hmmgs.txt

clean: 
	-( rm basic_hmmgs.txt *.fasta *.alignment *.stderr)

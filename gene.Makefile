hmmgs_result_prefix= gene_starts.txt

.PHONY: clean all

all: nucl_merged.fasta primers primers/primer_summary.txt

basic_hmmgs.txt: $(BLOOM)
	(java -Xmx$(MAX_JVM_HEAP) -jar $(JAR_DIR)/hmmgs.jar search 1 30 $(BLOOM) for_enone.hmm rev_enone.hmm $(hmmgs_result_prefix) > basic_hmmgs.txt 2> hmmgs.stderr) || (rm basic_hmmgs.txt && false)

nucl_merged.fasta: $(hmmgs_result_prefix)_nucl.fasta
	java -Xmx4g -jar $(JAR_DIR)/hmmgs.jar merge --min-bits $(MIN_BITS) --min-length $(MIN_LENGTH) for_enone.hmm basic_hmmgs.txt $(hmmgs_result_prefix)_nucl.fasta &> merge_stats.txt

primers:
	mkdir primers

$(hmmgs_result_prefix)_prot.fasta: basic_hmmgs.txt
$(hmmgs_result_prefix)_nucl.fasta: basic_hmmgs.txt

nucl_cdhit.fasta: nucl_merged.fasta
	$(CDHIT)-est -i nucl_merged.fasta -o nucl_cdhit.fasta -c .97

primers/experimental_primers.txt:
	touch primers/experimental_primers.txt

primers/primer_summary.txt: aligned_nucl.fasta primers/experimental_primers.txt
	cd primers && source $(PYTHON_VIRTENV)/bin/activate && ($(GLOWING_SAKANA)/seq_utils/primer_check.py $(JAR_DIR)/ProbeMatch.jar $(JAR_DIR)/ReadSeq.jar $(WEBLOGO) experimental_primers.txt ../aligned_nucl.fasta 2 > primer_summary.txt || rm primer_summary.txt)

align: aligned_prot.fasta aligned_nucl.fasta

aligned_prot.sto: prot_merged.fasta
	$(HMMALIGN) --allcol -o aligned_prot.sto for_enone.hmm prot_merged.fasta

aligned_prot.fasta: aligned_prot.sto
	java -cp $(JAR_DIR)/ReadSeq.jar edu.msu.cme.rdp.readseq.ToFasta aligned_prot.sto > aligned_prot.fasta || rm aligned_prot.fasta

aligned_nucl.fasta: aligned_prot.fasta nucl_cdhit.fasta
	java -cp $(JAR_DIR)/FungeneUtils.jar edu.msu.cme.rdp.fungene.cli.AlignNuclCmd aligned_prot.fasta nucl_cdhit.fasta aligned_nucl.fasta /dev/null


clean: 
	-( rm basic_hmmgs.txt *.fasta *.alignment *.stderr)

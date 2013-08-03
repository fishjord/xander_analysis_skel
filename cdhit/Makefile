.PHONY: all clean

all: cdhit_$(ASSEMBLY_FILE) cdhit_unmerged.fasta

cdhit_$(ASSEMBLY_FILE): ../all_contigs/$(ASSEMBLY_FILE)
	$(CDHIT)-est -i ../all_contigs/$(ASSEMBLY_FILE) -o cdhit_$(ASSEMBLY_FILE) -c 1

cdhit_unmerged.fasta: ../all_contigs/unmerged.fasta
	$(CDHIT)-est -i ../all_contigs/unmerged.fasta -o cdhit_unmerged.fasta -c 1

clean:
	-( rm *cdhit* *~)
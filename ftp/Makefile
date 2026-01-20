#
# Extract data from downloads
#
#
# NEED TO ADD UNIQ AFTER EVERY SORT!!!!
#
#default: genome_lineage.genome_id.poxviridae.txt
#default: genome_summary.genome_length100k.contigs1.poxviridate.txt
#default: genome_metadata.poxviridae.txt
default: Poxviridae.filt.fna

#
# get genome_ids for just Poxviridae
#
genome_lineage.genome_id.poxviridae.txt: genome_lineage
	awk 'BEGIN{FS="\t";OFS=FS;genome_id=1;family=8}($$family=="Poxviridae"||NR==1){print $$genome_id}' $< > $@


#
# filter genome_summary by just valide poxviridae genomes
#
genome_summary.genome_length100k.contigs1.poxviridate.txt: genome_summary genome_lineage.genome_id.poxviridae.txt
	sort genome_lineage.genome_id.poxviridae.txt > genome_lineage.genome_id.poxviridae.txt.sort
	sort genome_summary > genome_summary.sort
	join -t $$'\t' genome_lineage.genome_id.poxviridae.txt.sort genome_summary.sort | sort > $@
	wc -l $@ genome_lineage.genome_id.poxviridae.txt

#
# get metadata on just our filtered genomes
#
genome_metadata.accessions.sort: genome_metadata
	cut -f 1,19 $< | sort > $@

#grep -w -f <(cut -f 1 genome_summary.genome_length100k.contigs1.poxviridate.txt) genome_metadata > genome_metadata.filt.txt
genome_metadata.poxviridae.txt: genome_summary.genome_length100k.contigs1.poxviridate.txt genome_metadata.accessions.sort
	join -t $$'\t' genome_summary.genome_length100k.contigs1.poxviridate.txt genome_metadata.accessions.sort > $@

genome_accessions.txt: genome_metadata.poxviridae.txt
	cut -f 21 $< | sort > $@

#
# extract sequences - must be done by GENBANK_ACCESSION!
#
Poxviridae.fna.fai: Poxviridae.fna
	samtools faidx $<

Poxviridae.fna.accessions.txt: Poxviridae.fna.fai
	cut -f 1 $< | sort > $@

# remove genomes w/o sequence (bug workaround - they should all have sequence)
Poxviridae.fna.avail.accessions.txt: Poxviridae.fna.accessions.txt genome_accessions.txt
	join Poxviridae.fna.accessions.txt genome_accessions.txt > $@


Poxviridae.filt.fna: Poxviridae.fna Poxviridae.fna.avail.accessions.txt
	cat Poxviridae.fna.avail.accessions.txt | grep -v accession | xargs samtools faidx Poxviridae.fna > $@
	grep -c "^>" Poxviridae.fna $@

qc:
	wc -l genome_lineage.genome_id.poxviridae.txt genome_metadata.poxviridae.txt  genome_accessions.txt  Poxviridae.fna.fai Poxviridae.fna.avail.accessions.txt
	grep -c "^>" Poxviridae.fna Poxviridae.filt.fna
	comm -12 Poxviridae.fna.accessions.txt genome_accessions.txt | wc -l 
	comm -23 Poxviridae.fna.accessions.txt genome_accessions.txt | wc -l 
	comm -13 Poxviridae.fna.accessions.txt genome_accessions.txt | wc -l 

clean:
	rm *.sort
	rm *.fai
	rm genome*.txt Pox*.txt
	rm *filt*

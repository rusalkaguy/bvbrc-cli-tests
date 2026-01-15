#!/usr/bin/env bash
#
# Pull all "complete" Orthopoxvirus genome SEQUENCES
#
# once with piped commands, once with a single command
#
OUT_DIR=./out
FA_100_OUT=$OUT_DIR/bv-brc.orthopoxvirus.genome_length100k.seqs100.fasta
ID_100_OUT=$OUT_DIR/bv-brc.orthopoxvirus.genome_length100k.seqs100.txt
FA_500_OUT=$OUT_DIR/bv-brc.orthopoxvirus.genome_length100k.seqs500.fasta
ID_500_OUT=$OUT_DIR/bv-brc.orthopoxvirus.genome_length100k.seqs500.txt

cat <<EOF

# check BV-BRC CLI install
EOF
for ENV in /vol/patric3/cli/user-env.sh /Applications/BV-BRC.app/user-env.zsh; do
    if [[ -z "$(which p3-all-genomes 2>/dev/null)" && -e $ENV ]]; then
	echo source $ENV
	source $ENV
	break
    fi
done

echo which p3-all-genomes: $(which p3-all-genomes 2>/dev/null)
if [[ -z "$(which p3-all-genomes 2>/dev/null)" ]]; then
    echo "ERROR: BV-BRC CLI not installed"
    echo "Visit https://www.bv-brc.org/docs//cli_tutorial/cli_installation.html"
    exit 1
fi

cat <<EOF

# ----------------------------------------------------------------------
#
# fetch 3 pox sequences, view first 100 nt
#    genome-hsv1.genome.uab.edu: real	0m2.203s
#    peach.cels.anl.gov: 	 real	0m3.102s
#
# ----------------------------------------------------------------------
EOF
echo "p3-all-genomes --limit 3 \
  --eq 'genus,Orthopoxvirus' \
  --gt genome_length,100000 \
  --attr genome_name \
  --attr genbank_accessions \
 | p3-get-genome-contigs --col genome_id --attr sequence \
 | p3-extract genbank_accessions genome_name sequence \
 | awk 'BEGIN{FS=\"\t\"}(NR>1){print \">\"$1\" \"$2\"\n\"$3}' \
 | cut -c 1-100 \
"
time ( p3-all-genomes --limit 3 \
		      --eq "genus,Orthopoxvirus" \
		      --gt genome_length,100000 \
		      --attr genome_name \
		      --attr genbank_accessions \
	   | p3-get-genome-contigs --col genome_id --attr sequence \
	   | p3-extract genbank_accessions genome_name sequence \
	   | awk 'BEGIN{FS="\t"}(NR>1){print ">"$1" "$2"\n"$3}' \
	   | cut -c 1-100 \
) 

cat <<EOF

# ----------------------------------------------------------------------
#
# fetch 100 pox genomes
#    genome-cov1.genome.uab.edu:	total   0m57.516s (0.58 seconds each)
#    peach.cels.anl.gov: 	 	real	0m10.793s
#
# ----------------------------------------------------------------------

# query IDs -> $ID_500_OUt
EOF
echo " \
  p3-all-genomes --limit 100 \
  --eq 'genus,Orthopoxvirus' \
  --gt 'genome_length,100000' \
  --eq 'contigs,1' \
  --attr genome_name --attr genbank_accessions \
  > $ID_100_OUT
"
time ( \
  p3-all-genomes --limit 100 \
  --eq 'genus,Orthopoxvirus' \
  --gt 'genome_length,100000' \
  --eq 'contigs,1' \
  --attr genome_name --attr genbank_accessions \
  > $ID_100_OUT \
)
wc -l $ID_100_OUT

cat <<EOF

# query sequneces -> $FA_100_OUT
EOF
echo " \
  p3-all-genomes --limit 100 \
  --gt 'genome_length,100000' \
  --eq 'contigs,1' \
  --eq 'genus,Orthopoxvirus' \
  --attr genome_name --attr genbank_accessions \
      | p3-get-genome-contigs --col genome_id --attr sequence \
      | p3-extract genbank_accessions genome_name sequence \
      | awk 'BEGIN{FS=\"\t\"}(NR>1){print \">\"\$1\" \"\$2\"\n\"\$3}' \
      > $FA_100_OUT ) \
"

time ( p3-all-genomes --limit 100 \
		      --eq 'genus,Orthopoxvirus' \
		      --gt genome_length,100000 \
		      --eq 'contigs,1' \
		      --attr genome_name \
		      --attr genbank_accessions \
	   | p3-get-genome-contigs --col genome_id --attr sequence \
	   | p3-extract genbank_accessions genome_name sequence \
	   | awk 'BEGIN{FS="\t"}(NR>1){print ">"$1" "$2"\n"$3}' \
		 > $FA_100_OUT \
     )
echo "grep -c '>' $FA_100_OUT"
grep -c '>' $FA_100_OUT

cat <<EOF

# check IDs 
EOF
echo "diff --color  <(cut -f 3 $ID_100_OUT | sort) <(grep '>'  $FA_100_OUT | cut -c 2- | awk '{print $1}'|sort)"
diff --color  <(cut -f 3 $ID_100_OUT | sort) <(grep '>'  $FA_100_OUT | cut -c 2- | awk '{print $1}'|sort)

cat <<EOF

# ----------------------------------------------------------------------
#
# fetch 500 pox genomes:
# 	genome-hsv1.genome.uab.edu:	total	3m39.64s (0.44 seconds each)
# 	genome-hsv1.genome.uab.edu:	real	4m13.542s
#	peach.cels.anl.gov: 	 	real	0m55.873s (0.12 seconds each)
#
# ----------------------------------------------------------------------

# query IDs -> $ID_500_OUt
EOF
echo " \
  p3-all-genomes --limit 500 \
  --eq 'genus,Orthopoxvirus' \
  --gt 'genome_length,100000' \
  --eq 'contigs,1' \
  --attr genome_name --attr genbank_accessions \
  > $ID_500_OUT
"
time ( \
  p3-all-genomes --limit 500 \
  --eq 'genus,Orthopoxvirus' \
  --gt 'genome_length,100000' \
  --eq 'contigs,1' \
  --attr genome_name --attr genbank_accessions \
  > $ID_500_OUT \
)
wc -l $ID_500_OUT


cat <<EOF

# query sequneces -> $FA_500_OUT
EOF
echo " \
  p3-all-genomes --limit 500 \
  --eq 'genus,Orthopoxvirus' \
  --gt genome_length,100000 --attr genome_name --attr genbank_accessions \
      | p3-get-genome-contigs --col genome_id --attr sequence \
      | p3-extract genbank_accessions genome_name sequence \
      | awk 'BEGIN{FS=\"\t\"}(NR>1){print \">\"\$1\" \"\$2\"\n\"\$3}' \
      > $FA_500_OUT ) \
"

time ( p3-all-genomes --limit 500 \
		      --eq 'genus,Orthopoxvirus' \
		      --gt genome_length,100000 --attr genome_name --attr genbank_accessions \
	   | p3-get-genome-contigs --col genome_id --attr sequence \
	   | p3-extract genbank_accessions genome_name sequence \
	   | awk 'BEGIN{FS="\t"}(NR>1){print ">"$1" "$2"\n"$3}' \
		 > $FA_500_OUT \
     )
echo "grep -c '>' $FA_500_OUT"
grep -c '>' $FA_500_OUT

cat <<EOF

# check IDs 
EOF
echo "diff --color  <(cut -f 3 $ID_500_OUT | sort) <(grep '>'  $FA_500_OUT | cut -c 2- | awk '{print $1}'|sort)"
diff --color  <(cut -f 3 $ID_500_OUT | sort) <(grep '>'  $FA_500_OUT | cut -c 2- | awk '{print $1}'|sort)

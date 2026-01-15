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
 | p3-tbl-to-fasta genome_id sequence -k genbank_accessions -k genome_name \
 | grep -A 3 '>' \
"
time ( p3-all-genomes --limit 3 \
		      --eq "genus,Orthopoxvirus" \
		      --gt genome_length,100000 \
		      --attr genome_name \
		      --attr genbank_accessions \
	   | p3-get-genome-contigs --col genome_id --attr sequence \
	   | p3-tbl-to-fasta genome_id sequence -k genbank_accessions -k genome_name \
	   | grep -A 3 '>' \
) 

cat <<EOF

# ----------------------------------------------------------------------
#
# fetch 100 pox genomes
#    genome-cov1.genome.uab.edu:	total   0m57.516s (0.58 seconds each)
#    peach.cels.anl.gov: 	 	real	0m10.793s
#
# ----------------------------------------------------------------------

EOF
FETCH_COUNT=100
FA_OUT=$FA_100_OUT
ID_OUT=$ID_100_OUT
echo "# query IDs -> $ID_OUT"

echo " \
  p3-all-genomes --limit $FETCH_COUNT \
  --eq 'genus,Orthopoxvirus' \
  --gt 'genome_length,100000' \
  --eq 'contigs,1' \
  --attr genome_name --attr genbank_accessions \
  > $ID_OUT
"
time ( \
  p3-all-genomes --limit $FETCH_COUNT \
  --eq 'genus,Orthopoxvirus' \
  --gt 'genome_length,100000' \
  --eq 'contigs,1' \
  --attr genome_name --attr genbank_accessions \
  > $ID_OUT \
)
wc -l $ID_OUT

cat <<EOF

# query sequneces -> $FA_OUT
EOF
echo " \
  p3-all-genomes --limit $FETCH_COUNT \
  --gt 'genome_length,100000' \
  --eq 'contigs,1' \
  --eq 'genus,Orthopoxvirus' \
  --attr genome_name --attr genbank_accessions \
      | p3-get-genome-contigs --col genome_id --attr sequence \
      | p3-tbl-to-fasta genome_id sequence -k genbank_accessions -k genome_name \
      > $FA_OUT ) \
"

time ( p3-all-genomes --limit $FETCH_COUNT \
		      --eq 'genus,Orthopoxvirus' \
		      --gt genome_length,100000 \
		      --eq 'contigs,1' \
		      --attr genome_name \
		      --attr genbank_accessions \
	   | p3-get-genome-contigs --col genome_id --attr sequence \
	   | p3-tbl-to-fasta genome_id sequence -k genbank_accessions -k genome_name \
		 > $FA_OUT \
     )
echo "grep -c '>' $FA_OUT"
grep -c '>' $FA_OUT

# check counts
SEQ_COUNT=$(grep -c '>' $FA_OUT)
if [[ "$SEQ_COUNT" -ne "$FETCH_COUNT" ]]; then
    echo "ERROR: incorrect number of sequences returned $SEQ_COUNT \!= $FETCH_COUNT"
    exit 1
else
    echo "SUCCESS: correct number of sequences returned $SEQ_COUNT == $FETCH_COUNT"
fi

cat <<EOF

# check IDs 
EOF
echo "diff --color  <(p3-extract genome_id -i $ID_OUT | tail -n +2 | sort) <(grep '>'  $FA_OUT | cut -c 2- | awk '{print \$1}'|sort)"
diff --color  <(p3-extract genome_id -i $ID_OUT | tail -n +2 | sort) <(grep '>'  $FA_OUT | cut -c 2- | awk '{print $1}'|sort)



cat <<EOF

# ----------------------------------------------------------------------
#
# fetch 500 pox genomes:
# 	genome-hsv1.genome.uab.edu:	total	3m39.64s (0.44 seconds each)
# 	genome-hsv1.genome.uab.edu:	real	4m13.542s
#	peach.cels.anl.gov: 	 	real	0m55.873s (0.12 seconds each)
#
# ----------------------------------------------------------------------

EOF
FETCH_COUNT=500
FA_OUT=$FA_500_OUT
ID_OUT=$ID_500_OUT
echo "# query IDs -> $ID_OUT"

echo " \
  p3-all-genomes --limit $FETCH_COUNT \
  --eq 'genus,Orthopoxvirus' \
  --gt 'genome_length,100000' \
  --eq 'contigs,1' \
  --attr genome_name --attr genbank_accessions \
  > $ID_OUT
"
time ( \
  p3-all-genomes --limit $FETCH_COUNT \
  --eq 'genus,Orthopoxvirus' \
  --gt 'genome_length,100000' \
  --eq 'contigs,1' \
  --attr genome_name --attr genbank_accessions \
  > $ID_OUT \
)
wc -l $ID_OUT


cat <<EOF

# query sequneces -> $FA_OUT
EOF
echo " \
  p3-all-genomes --limit $FETCH_COUNT \
  --eq 'genus,Orthopoxvirus' \
  --gt genome_length,100000 --attr genome_name --attr genbank_accessions \
      | p3-get-genome-contigs --col genome_id --attr sequence \
      | p3-tbl-to-fasta genome_id sequence -k genbank_accessions -k genome_name \
      > $FA_OUT ) \
"

time ( p3-all-genomes --limit $FETCH_COUNT \
		      --eq 'genus,Orthopoxvirus' \
		      --gt genome_length,100000 --attr genome_name --attr genbank_accessions \
	   | p3-get-genome-contigs --col genome_id --attr sequence \
	   | p3-tbl-to-fasta genome_id sequence -k genbank_accessions -k genome_name \
		 > $FA_OUT \
     )
echo "grep -c '>' $FA_OUT"
grep -c '>' $FA_OUT
SEQ_COUNT=$(grep -c '>' $FA_OUT)
if [[ "$SEQ_COUNT" -ne "$FETCH_COUNT" ]]; then
    echo "ERROR: incorrect number of sequences returned $SEQ_COUNT \!= $FETCH_COUNT"
    exit 1
else
    echo "SUCCESS: correct number of sequences returned $SEQ_COUNT == $FETCH_COUNT"
fi

cat <<EOF

# check IDs 
EOF
echo "diff --color  <(p3-extract genome_id -i $ID_OUT | tail -n +2 | sort) <(grep '>'  $FA_OUT | cut -c 2- | awk '{print \$1}'|sort)"
diff --color  <(p3-extract genome_id -i $ID_OUT | tail -n +2 | sort) <(grep '>'  $FA_OUT | cut -c 2- | awk '{print $1}'|sort)


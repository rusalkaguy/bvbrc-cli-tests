#!/usr/bin/env bash
#
# Pull all "complete" Orthopoxvirus genome SEQUENCES
#
# once with piped commands, once with a single command
#
OUT_DIR=./out
FA_OUT=$OUT_DIR/bv-brc.orthopoxvirus.genome_length100k.seqs.fasta

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
#    genome-cov1 @ UAB: 57.516s total (0.58 seconds each)
#
# ----------------------------------------------------------------------
EOF
echo " \
  p3-all-genomes --limit 100 \
  --eq 'genus,Orthopoxvirus' \
  --gt genome_length,100000 --attr genome_name --attr genbank_accessions \
      | p3-get-genome-contigs --col genome_id --attr sequence \
      | p3-extract genbank_accessions genome_name sequence \
      | awk 'BEGIN{FS=\"\t\"}(NR>1){print \">\"$1\" \"$2\"\n\"$3}' \
      > $FA_OUT ) \
"

time ( p3-all-genomes --limit 100 \
		      --eq 'genus,Orthopoxvirus' \
		      --gt genome_length,100000 --attr genome_name --attr genbank_accessions \
	   | p3-get-genome-contigs --col genome_id --attr sequence \
	   | p3-extract genbank_accessions genome_name sequence \
	   | awk 'BEGIN{FS="\t"}(NR>1){print ">"$1" "$2"\n"$3}' \
		 > $FA_OUT \
     )
echo "grep -c '>' $FA_OUT"
grep -c '>' $FA_OUT

cat <<EOF

# ----------------------------------------------------------------------
#
# fetch 500 pox genomes:
#   genome-hsv1 @ UAB: 3m39.64s total (0.44 seconds each)
#
# ----------------------------------------------------------------------
EOF
echo " \
  p3-all-genomes --limit 500 \
  --eq 'genus,Orthopoxvirus' \
  --gt genome_length,100000 --attr genome_name --attr genbank_accessions \
      | p3-get-genome-contigs --col genome_id --attr sequence \
      | p3-extract genbank_accessions genome_name sequence \
      | awk 'BEGIN{FS=\"\t\"}(NR>1){print \">\"$1\" \"$2\"\n\"$3}' \
      > $FA_OUT ) \
"

time ( p3-all-genomes --limit 500 \
		      --eq 'genus,Orthopoxvirus' \
		      --gt genome_length,100000 --attr genome_name --attr genbank_accessions \
	   | p3-get-genome-contigs --col genome_id --attr sequence \
	   | p3-extract genbank_accessions genome_name sequence \
	   | awk 'BEGIN{FS="\t"}(NR>1){print ">"$1" "$2"\n"$3}' \
		 > $FA_OUT \
     )
echo "grep -c '>' $FA_OUT"
grep -c '>' $FA_OUT

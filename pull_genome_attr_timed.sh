#!/usr/bin/env bash
#
# Pull all "complete" Orthopoxvirus genomes
#
# once with piped commands, once with a single command
#
OUT_DIR=./out
META_OUT=$OUT_DIR/bv-brc.orthopoxvirus.gc_content-vs-genome_length.txt

cat <<EOF

# check BV-BRC CLI install
EOF
echo which p3-all-genomes: $(which p3-all-genomes 2>/dev/null)
if [[ -z "$(which p3-all-genomes 2>/dev/null)" ]]; then
    echo "ERROR: BV-BRC CLI not installed"
    echo "Visit https://www.bv-brc.org/docs//cli_tutorial/cli_installation.html"
    exit 1
fi

cat <<EOF

# ----------------------------------------------------------------------
#
# count, only
#
# ----------------------------------------------------------------------
EOF
echo p3-all-genomes -K \
  --eq "genus,Orthopoxvirus" \
  --gt genome_length,100000
time p3-all-genomes -K \
  --eq "genus,Orthopoxvirus" \
  --gt genome_length,100000

cat <<EOF

# ----------------------------------------------------------------------
#
# filter and pull IDs, one command
#
# ----------------------------------------------------------------------
EOF
echo 'p3-all-genomes \
  --eq "genus,Orthopoxvirus" \
  --gt genome_length,100000 \
  --attr species \
  --attr gc_content \
  --attr genome_length \
  --attr genome_name \
  --attr genbank_accessions \
  > bv-brc.orthopoxvirus.gc_content-vs-genome_length.txt \
'
time (
    p3-all-genomes \
  --eq "genus,Orthopoxvirus" \
  --gt genome_length,100000 \
  --attr species \
  --attr gc_content \
  --attr genome_length \
  --attr genome_name \
  --attr genbank_accessions \
  > bv-brc.orthopoxvirus.gc_content-vs-genome_length.txt \
)
wc -l bv-brc.orthopoxvirus.gc_content-vs-genome_length.txt

cat <<EOF

# ----------------------------------------------------------------------
#
# pull IDs | fetch attrs
#
# ----------------------------------------------------------------------
EOF
echo "p3-all-genomes \
  --eq 'genus,Orthopoxvirus' \
  --gt genome_length,100000 \
  | p3-get-genome-data
  --attr species \
  --attr gc_content \
  --attr genome_length \
  --attr genome_name \
  --attr genbank_accessions \
  > $META_OUT
"
time ( \
    p3-all-genomes \
  --eq "genus,Orthopoxvirus" \
  --gt genome_length,100000 \
  | p3-get-genome-data \
  --attr species \
  --attr gc_content \
  --attr genome_length \
  --attr genome_name \
  --attr genbank_accessions \
  > $META_OUT \
)
wc -l $META_OUT

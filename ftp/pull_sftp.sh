#!/usr/bin/env bash
#
# CLI SFTP download from BV-BRC
#

#
# curl
#time curl -K curl_cmds_urls.txt
USER=anonymous:guest
SERVER=ftp://ftp.bv-brc.org
SRC=curl_files.txt

wc -l $SRC
RC=$?
if [ $RC -ne 0 ]; then
    echo "ERROR: $SRC"
    exit $RC
fi

for FILE in \
    $(egrep -v "^#"  curl_files.txt) \
    ; do

    echo "curl --ssl-reqd -O --user 'anonymous,guest' '$SERVER/$FILE'"
    curl --ssl-reqd -O --user "$USER" "$SERVER/$FILE"
done 

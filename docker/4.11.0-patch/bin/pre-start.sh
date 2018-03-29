#!/bin/bash
set -e

echo "uaa-pre-start - starting at `date`"

if [ -f /.pre_start_created ]; then
    echo "pre_start' already created"
    exit 0
fi

CERT_FILE=/etc/ssl/certs/ca-certificates.crt

CACHE_DIR=/usr/local/uaa/cert-cache

mkdir -p $CACHE_DIR

CERT_CACHE_FILE=$CACHE_DIR/cacerts-cache.txt
TRUST_STORE_FILE=$CACHE_DIR/cacerts

CERTS=$(grep 'END CERTIFICATE' $CERT_FILE| wc -l)

function process_certs {
    echo "Processing certificates for Java cacerts file"
    rm -f $CERT_CACHE_FILE
    rm -f $TRUST_STORE_FILE
    COUNTER=0
    for N in $(seq 0 $(($CERTS - 1))); do
      # Get the alias
      ALIAS="${CERT_FILE%.*}-$N"
      # Load the cert into the Java keystore
      cat $CERT_FILE |
        awk "n==$N { print }; /END CERTIFICATE/ { n++ }" |
          keytool -noprompt \
                  -import \
                  -trustcacerts \
                  -alias $ALIAS \
                  -keystore $TRUST_STORE_FILE \
                  -storepass changeit
      let COUNTER=COUNTER+1
      echo "Processed certificate $COUNTER of $CERTS"
    done
    if [ "$COUNTER" -eq "$CERTS" ]; then
        echo "Java keystore creation completed."
        cp $CERT_FILE $CERT_CACHE_FILE
    fi
}

if [ -a $CERT_CACHE_FILE ] && [ -a $TRUST_STORE_FILE ]; then
    if  diff $CERT_CACHE_FILE $CERT_FILE >/dev/null; then
      echo "No changes to CA certificates. Will not build Java keystore file."
    else
      echo "Changes to CA certificates detected."
      process_certs
    fi
else
    process_certs
fi

touch /.pre_start_created

echo "uaa-pre-start - completed at `date`"

exit 0

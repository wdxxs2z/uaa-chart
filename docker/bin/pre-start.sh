#!/bin/bash
set -e

echo "uaa-pre-start - starting at `date`"

if [ -f /.pre_start_created ]; then
    echo "pre_start' already created"
    exit 0
fi

CERT_FILE=/etc/ssl/certs/ca-certificates.crt

CONF_DIR=/usr/local/uaa/config
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

function setup_directories {
    mkdir -p /var/log/uaa
    cp -a /usr/local/uaa/config/tomcat/* /usr/local/tomcat/conf/
    rm -rf $KEY_STORE_FILE
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

if [ $UAA_LDAP_SSL == 'true' ]; then
    echo "[uaa-pre-start] Installing LDAP certificate"
    /usr/local/uaa/bin/install_crt /usr/local/uaa/config/ldap.crt ldapcert $TRUST_STORE_FILE
    echo "[uaa-pre-start] Installed LDAP certificate"
fi

# Install the server's ssl certificate
if [ $UAA_SSL == 'true' ]; then
    echo "[uaa-pre-start] Generate self pem"
    /usr/local/uaa/bin/generate_crt
    echo "[uaa-pre-start] Installing Server SSL certificate"
    /usr/local/uaa/bin/install_uaa_crt /usr/local/uaa/config/uaa.pem
    echo "[uaa-pre-start] Installed Server SSL certificate"
fi

cp $TRUST_STORE_FILE $CONF_DIR

setup_directories

touch /.pre_start_created

echo "uaa-pre-start - completed at `date`"

exit 0

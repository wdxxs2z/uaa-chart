#!/bin/bash
set -e

echo "uaa-pre-setup-dirs - starting at `date`"

CONF_DIR=/usr/local/uaa
CACHE_DIR=/usr/local/uaa/cert-cache
TRUST_STORE_FILE=$CACHE_DIR/cacerts
CERT_CACHE_FILE=$CACHE_DIR/cacerts-cache.txt

function setup_directories {
    echo "Copy directories files..."
    mkdir -p /var/log/uaa
    cp /usr/local/uaa/config/tomcat/server.xml /usr/local/tomcat/conf
    cp /usr/local/uaa/config/tomcat/context.xml /usr/local/tomcat/conf
    rm -rf $KEY_STORE_FILE
}

if [ "$UAA_LDAP_SSL" = "true" ]; then
    echo "[uaa-pre-start] Installing LDAP certificate"
    /usr/local/uaa/bin/install_crt /usr/local/uaa/config/ldap.crt ldapcert $TRUST_STORE_FILE
    echo "[uaa-pre-start] Installed LDAP certificate"
fi

# Install the server's ssl certificate
if [ "$UAA_SSL" = "true" ]; then
    echo "[uaa-pre-start] Generate self pem"
    /usr/local/uaa/bin/generate_crt
    echo "[uaa-pre-start] Installing Server SSL certificate"
    /usr/local/uaa/bin/install_uaa_crt /usr/local/uaa/uaa.pem
    echo "[uaa-pre-start] Installed Server SSL certificate"
fi

cp $TRUST_STORE_FILE $CONF_DIR

setup_directories

echo "uaa-pre-setup-dirs - completed at `date`"

exit 0

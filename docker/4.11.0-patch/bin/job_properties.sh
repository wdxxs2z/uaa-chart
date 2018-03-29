#!/usr/bin/env bash

if [ "$CLOUD_FOUNDRY_CONFIG_PATH" = "" ]; then
    export CLOUD_FOUNDRY_CONFIG_PATH=/usr/local/uaa/config
fi

export CATALINA_OPTS="-Xmx768m -XX:MaxPermSize=256m"

if [ "$EXTERNAL_URL" = "" ]; then
    export EXTERNAL_URL="external.io"
fi

if [ "$INTERNAL_URL" = "" ]; then
    export INTERNAL_URL="internal.io"
fi

if [ "$MYSQL_URL" = "" ]; then
    echo "MYSQL_URL value must be set."
    exit 1
fi

if [ "$MYSQL_PORT" = "" ]; then
    echo "MYSQL_PORT value must be set."
    exit 1
fi

if [ "$MYSQL_DB_NAME" = "" ]; then
    echo "MYSQL_DB_NAME value must be set."
    exit 1
fi

if [ "$MYSQL_USERNAME" = "" ]; then
    echo "MYSQL_USERNAME value must be set."
    exit 1
fi

if [ "$MYSQL_PASSWORD" = "" ]; then
    echo "MYSQL_PASSWORD value must be set."
    exit 1
fi

if [ "$KUBERNETES_CLIENT_SECRET" = "" ]; then
    export KUBERNETES_CLIENT_SECRET="changeme"
fi

if [ "$LOGIN_CLIENT_SECRET" = "" ]; then
    export LOGIN_CLIENT_SECRET="changeme"
fi

if [ "$ADMIN_CLIENT_SECRET" = "" ]; then
    export ADMIN_CLIENT_SECRET="changeme"
fi

if [ "$ADMIN_PASSWORD" = "" ]; then
    export ADMIN_PASSWORD="adminpassword"
fi

if [ "$UAA_SAML_KEY" = "" ]; then
    echo "UAA_SAML_KEY value must be set."
    exit 1
fi

if [ "$UAA_SAML_CERT" = "" ]; then
    echo "UAA_SAML_CERT value must be set."
    exit 1
fi

if [ "$UAA_SSL" = "" ]; then
    export UAA_SSL=true
fi

if [ "$UAA_LDAP_SSL" = "" ]; then
    export UAA_LDAP_SSL=false
fi

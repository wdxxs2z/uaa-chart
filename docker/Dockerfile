FROM tomcat:8.0-jre8-alpine

ENV UAA_VERSION 4.10.0

ENV CLOUD_FOUNDRY_CONFIG_PATH /usr/local/uaa/config

ENV CATALINA_OPTS "-Xmx768m -XX:MaxPermSize=256m"

ENV EXTERNAL_URL "domain.io"

ENV INTERNAL_URL "internal.io"

ENV MYSQL_URL "127.0.0.1"

ENV MYSQL_PORT 3306

ENV MYSQL_DB_NAME uaa

ENV MYSQL_USERNAME test

ENV MYSQL_PASSWORD changeme

ENV KUBERNETES_CLIENT_SECRET changeme

ENV LOGIN_CLIENT_SECRET changeme

ENV ADMIN_CLIENT_SECRET changeme

ENV ADMIN_PASSWORD changeme

ENV UAA_SAML_KEY ""

ENV UAA_SAML_CERT ""

ENV UAA_SSL true

ENV UAA_LDAP_SSL false

RUN rm -rf /usr/local/tomcat/webapps/ROOT

ADD http://central.maven.org/maven2/org/cloudfoundry/identity/cloudfoundry-identity-uaa/${UAA_VERSION}/cloudfoundry-identity-uaa-${UAA_VERSION}.war /usr/local/tomcat/webapps/ROOT.war

ADD /uaa-chart/docker/config /usr/local/uaa/

ADD /uaa-chart/docker/bin /usr/local/uaa/

EXPOSE 8080

FROM tomcat:8.0-jre8-alpine

ENV UAA_VERSION 4.10.0

RUN rm -rf /usr/local/tomcat/webapps/ROOT

ADD http://central.maven.org/maven2/org/cloudfoundry/identity/cloudfoundry-identity-uaa/${UAA_VERSION}/cloudfoundry-identity-uaa-${UAA_VERSION}.war /usr/local/tomcat/webapps/ROOT.war

ADD config /usr/local/uaa/

ADD bin /usr/local/uaa/

EXPOSE 8080

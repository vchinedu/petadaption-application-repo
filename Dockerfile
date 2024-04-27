FROM openjdk:8-jre-slim
FROM ubuntu
FROM tomcat
#copy war file on the container
COPY **/*.war /usr/local/tomcat/webapps
WORKDIR  /usr/local/tomcat/webapps
RUN apt update -y && apt install curl -y
RUN curl -O https://download.newrelic.com/newrelic/java-agent/newrelic-agent/current/newrelic-java.zip && \
    apt-get install unzip -y  && \
    unzip newrelic-java.zip -d  /usr/local/tomcat/webapps
ENV JAVA_OPTS="$JAVA_OPTS -javaagent:app/newrelic.jar"
ENV NEW_RELIC_APP_NAME="pet_adoption"
ENV NEW_RELIC_LOG_FILE_NAME=STDOUT
ENV NEW_RELIC_LICENCE_KEY="eu01xxfa24eabe12a78c355a6973ce5b51abNRAL"
WORKDIR /usr/local/tomcat/webapps
ADD ./newrelic.yml /usr/local/tomcat/webapps/newrelic/newrelic.yml
ENTRYPOINT [ "java", "-javaagent:/usr/local/tomcat/webapps/newrelic/newrelic.jar", "-jar", "spring-petclinic-2.4.2.war", "--server.port=8080"]



# FROM openjdk:8-jre-slim
# FROM ubuntu
# FROM tomcat
# #copy war file on the container
# COPY **/*.war /usr/local/tomcat/webapps
# WORKDIR  /usr/local/tomcat/webapps
# RUN apt update -y && apt install curl -y
# RUN curl -O https://download.newrelic.com/newrelic/java-agent/newrelic-agent/current/newrelic-java.zip && \
#     apt-get install unzip -y  && \
#     unzip newrelic-java.zip -d  /usr/local/tomcat/webapps
# ENV JAVA_OPTS="$JAVA_OPTS -javaagent:app/newrelic.jar"
# ENV NEW_RELIC_APP_NAME="petclinicapps"
# ENV NEW_RELIC_LOG_FILE_NAME=STDOUT
# ENV NEW_RELIC_LICENCE_KEY="eu01xx2761148396df10a82ea5423bb031e1NRAL"
# WORKDIR /usr/local/tomcat/webapps
# ADD ./newrelic.yml /usr/local/tomcat/webapps/newrelic/newrelic.yml
# ENTRYPOINT [ "java", "-javaagent:/usr/local/tomcat/webapps/newrelic/newrelic.jar", "-jar", "spring-petclinic-2.4.2.war", "--server.port=8080"]

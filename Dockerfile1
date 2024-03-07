# Step 1: Build the application
FROM maven:3.6.3-jdk-11 as build
WORKDIR /app

# Copy the source code
COPY src /app/src
# Copy the Maven configuration file
COPY pom.xml /app

# Package the application
RUN mvn clean package -DskipTests -Dcheckstyle.skip

# Step 2: Create the Docker container
FROM openjdk:11-jre-slim
WORKDIR /app

# Copy the packaged WAR file from the build stage to the container
COPY --from=build /app/target/spring-petclinic-*.war /app/app.war

# Download Newrelic Agent zip file, then Install Curl and Unzip to Unzip the file
RUN apt update -y && apt install curl -y
RUN curl -O https://download.newrelic.com/newrelic/java-agent/newrelic-agent/current/newrelic-java.zip && \
    apt-get install unzip -y  && \
    unzip newrelic-java.zip -d  /app

# Copy Newrelic yaml file with account config to the container
COPY newrelic.yml /app

# Run the application
#CMD ["java", "-jar", "app.war"]
ENTRYPOINT [ "java", "-javaagent:/app/newrelic/newrelic.jar", "-jar", "app.war", "--server.port=8080"]

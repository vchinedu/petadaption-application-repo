FROM openjdk:8-jre-slim
WORKDIR /app
COPY **/*.war /app
ENTRYPOINT ["java", "-jar", "spring-petclinic-2.4.2.war", "--server.port=8080"]

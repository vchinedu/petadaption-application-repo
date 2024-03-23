FROM openjdk:8-jre-slim
WORKDIR /app
#copy war file on the container
COPY **/*.war /app/app.war
EXPOSE 8080
CMD [ "java", "-jar", "app.war"]

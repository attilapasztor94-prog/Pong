# Pasul 1: Construim aplicația folosind Maven
FROM maven:3.8.5-openjdk-17 AS build
COPY src .
RUN mvn clean package -DskipTests

# Pasul 2: Luăm doar fișierul executabil și îl rulăm
FROM openjdk:17-jdk-slim
COPY --from=build /target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
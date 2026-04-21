# Pasul 1: Construim aplicația
FROM maven:3.8.5-openjdk-17 AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Pasul 2: Imaginea finală
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
# Am făcut copia mai specifică pentru a evita fișierele "-plain.jar"
COPY --from=build /app/target/Pong-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
# Pasul 1: Construim aplicația folosind o imagine oficială de Maven
FROM maven:3.8.5-openjdk-17 AS build
WORKDIR /app
COPY . .
# Rulăm mvn direct (fără ./) pentru a evita problemele de permisiuni
RUN mvn clean package -DskipTests

# Pasul 2: Imaginea finală, ușoară, pentru rulare
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
# Copiem jar-ul generat din pasul anterior
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
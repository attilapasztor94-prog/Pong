# Pasul 1: Build (folosim Temurin pentru stabilitate)
FROM eclipse-temurin:17-jdk-jammy AS build
WORKDIR /app
COPY . .
RUN chmod +x mvnw
RUN ./mvnw clean package -DskipTests

# Pasul 2: Run (imaginea de rulare, foarte mică)
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
# Copiem fișierul .jar generat la pasul anterior
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
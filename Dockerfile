# Folosim o imagine de Java 17 pentru build
FROM eclipse-temurin:17-jdk-jammy AS build

# Copiem toate fișierele proiectului în container
COPY . .

# Acordăm permisiuni de executare pentru scriptul Maven Wrapper (esențial pentru Linux/Render)
RUN chmod +x mvnw

# Construim fișierul .jar (sărim peste teste pentru a fi mai rapid)
RUN ./mvnw clean package -DskipTests

# Pasul de rulare: folosim o imagine mai mică (JRE) doar pentru a rula aplicația
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
COPY --from=build /target/*.jar app.jar

# Expunem portul pe care ascultă Spring Boot
EXPOSE 8080

# Comanda de pornire
ENTRYPOINT ["java", "-jar", "app.jar"]
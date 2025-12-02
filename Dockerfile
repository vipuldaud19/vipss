# ---- 1. Build Stage ----
FROM eclipse-temurin:23-jdk AS build

WORKDIR /app

# Copy pom.xml first to leverage Docker cache
COPY pom.xml .

# Install Maven (if mvnw is not present)
RUN apt-get update && apt-get install -y maven

# Download dependencies offline
RUN mvn dependency:go-offline

# Copy full project source
COPY src src

# Build the JAR file (skip tests to speed up Docker build)
RUN mvn clean package -DskipTests

# ---- 2. Runtime Stage ----
FROM eclipse-temurin:23-jre

WORKDIR /app

# Copy the JAR file from build stage
COPY --from=build /app/target/*.jar app.jar

# Expose the port Render will use
ENV PORT=8080
EXPOSE 8080

# Start the app
ENTRYPOINT ["java", "-jar", "app.jar"]

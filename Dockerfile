# ---- 1. Build Stage ----
FROM eclipse-temurin:23-jdk AS build

WORKDIR /app

# Copy Maven wrapper and pom.xml first
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

# Download dependencies
RUN chmod +x mvnw && ./mvnw dependency:go-offline

# Copy the entire project source
COPY src src

# Build the project (WAR file)
RUN ./mvnw clean package -DskipTests

# ---- 2. Runtime Stage ----
FROM eclipse-temurin:23-jre

WORKDIR /app

# Copy WAR file from build stage
COPY --from=build /app/target/*.war app.war

# Expose port for Render
EXPOSE 8080

# Render provides PORT env automatically
ENV PORT=8080

# Start app
ENTRYPOINT ["java", "-jar", "/app/app.war"]

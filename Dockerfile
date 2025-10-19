# --- Stage 1: The Build Stage ---
# Use an official Maven image with Java 17 to build the application
FROM maven:3.9.8-eclipse-temurin-17-focal AS build

# Set the working directory inside the container
WORKDIR /app

# Copy the Maven pom.xml file first
COPY pom.xml .

# Download dependencies (this layer is cached if pom.xml doesn't change)
RUN mvn dependency:go-offline

# Copy the rest of the source code
COPY src ./src

# Build the application, package it, and skip tests (Jenkins will run tests)
RUN mvn clean package -DskipTests

# --- Stage 2: The Final Stage ---
# Use a lightweight JRE image for the final container
FROM eclipse-temurin:17-jre-focal

# Set the working directory
WORKDIR /app

# Set an environment variable for the port
# This tells our Spring Boot app to run on 8090
ENV SERVER_PORT 8090

# Expose port 8090 to the outside world
EXPOSE 8090

# Copy the built .jar file from the 'build' stage
# The jar file is in /app/target/ and will be named portfolio-pipeline-0.0.1-SNAPSHOT.jar
# We'll rename it to app.jar for simplicity
COPY --from=build /app/target/*.jar app.jar

# Set the command to run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
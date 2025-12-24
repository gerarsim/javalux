# Full Multi-stage Docker build for Java + React application
# Compliance-ready for Luxembourg deployment

# Stage 1: Build React frontend
FROM node:18-alpine AS frontend-build
WORKDIR /app

# Copy package files from React app directory (in frontend/ folder)
COPY frontend/package*.json ./
RUN npm ci

# Copy frontend source and build
COPY frontend/public/ ./public/
COPY frontend/src/ ./src/
RUN npm run build

# Stage 2: Build Java backend
FROM maven:3.9-eclipse-temurin-17 AS backend-build
WORKDIR /app

# Copy Maven files
COPY pom.xml ./
RUN mvn dependency:go-offline -B

# Copy backend source (in root src/ folder)
COPY src/ ./src/
RUN mvn clean package -DskipTests -B

# Stage 3: Production image
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Install security updates
RUN apk update && apk upgrade && rm -rf /var/cache/apk/*

# Create non-root user for security compliance
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Copy built artifacts
COPY --from=backend-build /app/target/*.jar app.jar
COPY --from=frontend-build /app/build ./static

# Set up logging directory for audit trails (Luxembourg GDPR compliance)
RUN mkdir -p /app/logs /app/config && \
    chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# Expose port
EXPOSE 8080

# Environment variables for compliance
ENV JAVA_OPTS="-Xms512m -Xmx1024m \
    -Dspring.profiles.active=production \
    -Duser.timezone=Europe/Luxembourg \
    -Dfile.encoding=UTF-8 \
    -Djava.security.egd=file:/dev/./urandom"

# Run application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
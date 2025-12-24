# Multi-stage Docker build for Java + React application
# Compliance-ready for Luxembourg deployment

# Stage 1: Build React frontend
FROM node:18-alpine AS frontend-build
WORKDIR /app/frontend

# Copy package files
COPY frontend/package*.json ./
RUN npm ci --only=production

# Copy frontend source and build
COPY frontend/ ./
RUN npm run build

# Stage 2: Build Java backend
FROM maven:3.9-eclipse-temurin-17 AS backend-build
WORKDIR /app/backend

# Copy Maven files
COPY backend/pom.xml ./
RUN mvn dependency:go-offline

# Copy source and build
COPY backend/src ./src
RUN mvn clean package -DskipTests

# Stage 3: Production image
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Create non-root user for security compliance
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Copy built artifacts
COPY --from=backend-build /app/backend/target/*.jar app.jar
COPY --from=frontend-build /app/frontend/build ./static

# Set up logging directory for audit trails (Luxembourg GDPR compliance)
RUN mkdir -p /app/logs && \
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
    -Dfile.encoding=UTF-8"

# Run application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]

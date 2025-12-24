#!/bin/bash

# Diagnostic Script for Docker Compose Issues
# Checks why containers aren't starting

echo "========================================="
echo "Docker Compose Diagnostic Tool"
echo "========================================="
echo ""

# Check if docker-compose.yml exists
if [ ! -f docker-compose.yml ]; then
    echo "❌ ERROR: docker-compose.yml not found in current directory"
    echo "   Please run this script from your project directory"
    exit 1
fi

echo "✓ Found docker-compose.yml"
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo "⚠️  WARNING: .env file not found"
    echo "   Creating from template..."
    if [ -f .env.template ]; then
        cp .env.template .env
        echo "   ✓ Created .env from template"
        echo "   ⚠️  You MUST edit .env and set passwords before running docker-compose up"
        echo ""
    else
        echo "   ❌ .env.template not found either"
        echo "   Creating minimal .env file..."
        cat > .env << 'ENVEOF'
DB_PASSWORD=changeme_secure_password
JWT_SECRET=changeme_jwt_secret_minimum_32_characters_long
ENCRYPTION_KEY=changeme_encryption_key_minimum_32_chars
ENVEOF
        echo "   ✓ Created basic .env file"
        echo "   ⚠️  SECURITY WARNING: Change all passwords before production!"
        echo ""
    fi
fi

# Check for JAR file
echo "Checking for application JAR file..."
jar_count=$(ls -1 *.jar 2>/dev/null | wc -l)
if [ $jar_count -eq 0 ]; then
    echo "❌ ERROR: No JAR file found in current directory"
    echo ""
    echo "You need a Spring Boot JAR file to run this application."
    echo ""
    echo "Options:"
    echo "  1. Build your Spring Boot app: mvn clean package"
    echo "     Then: cp target/your-app.jar app.jar"
    echo ""
    echo "  2. Download demo app for testing:"
    echo "     curl -L -o app.jar https://github.com/spring-projects/spring-petclinic/releases/download/v3.1.0/spring-petclinic-3.1.0.jar"
    echo ""
    exit 1
else
    jar_file=$(ls -1 *.jar | head -1)
    jar_size=$(du -h "$jar_file" | cut -f1)
    echo "✓ Found JAR file: $jar_file ($jar_size)"
fi
echo ""

# Check Docker daemon
echo "Checking Docker daemon..."
if ! docker info > /dev/null 2>&1; then
    echo "❌ ERROR: Docker daemon is not running"
    echo "   Start Docker with: sudo systemctl start docker"
    exit 1
fi
echo "✓ Docker daemon is running"
echo ""

# Check for running containers
echo "Checking container status..."
running=$(docker-compose ps -q | wc -l)
if [ $running -eq 0 ]; then
    echo "⚠️  No containers are currently running"
    echo ""
    echo "Checking if containers exist but are stopped..."
    all_containers=$(docker-compose ps -a -q | wc -l)
    if [ $all_containers -gt 0 ]; then
        echo "Found $all_containers stopped container(s)"
        echo ""
        echo "Container status:"
        docker-compose ps -a
        echo ""
        echo "Last container logs:"
        docker-compose logs --tail=50
        echo ""
    else
        echo "No containers exist yet. Run: docker-compose up -d"
    fi
else
    echo "✓ Found $running running container(s)"
    docker-compose ps
fi
echo ""

# Check for port conflicts
echo "Checking for port conflicts..."
for port in 80 443 8080 5432; do
    if netstat -tuln 2>/dev/null | grep -q ":$port " || ss -tuln 2>/dev/null | grep -q ":$port "; then
        echo "⚠️  Port $port is in use"
        echo "   Check with: sudo lsof -i :$port"
    fi
done
echo ""

# Check Dockerfile
echo "Checking Dockerfile..."
if [ ! -f Dockerfile ]; then
    echo "❌ ERROR: Dockerfile not found"
    exit 1
fi

if grep -q "COPY frontend/" Dockerfile; then
    echo "⚠️  WARNING: Dockerfile expects /frontend directory but none found"
    echo "   You need to replace this Dockerfile with the simple version"
    echo "   See IMMEDIATE_FIX.md for instructions"
fi

if grep -q "COPY backend/" Dockerfile; then
    echo "⚠️  WARNING: Dockerfile expects /backend directory but none found"
    echo "   You need to replace this Dockerfile with the simple version"
    echo "   See IMMEDIATE_FIX.md for instructions"
fi
echo ""

# Summary and recommendations
echo "========================================="
echo "Summary"
echo "========================================="
echo ""

if [ $jar_count -eq 0 ]; then
    echo "❌ BLOCKER: No JAR file found - cannot proceed"
    echo ""
    echo "Next steps:"
    echo "  1. Add your JAR file (see options above)"
    echo "  2. Run: docker-compose build"
    echo "  3. Run: docker-compose up -d"
elif [ ! -f .env ]; then
    echo "⚠️  Configure .env file before starting"
    echo ""
    echo "Next steps:"
    echo "  1. Edit .env and set passwords"
    echo "  2. Run: docker-compose build"
    echo "  3. Run: docker-compose up -d"
else
    echo "✓ Basic requirements met"
    echo ""
    echo "Ready to build and start:"
    echo "  docker-compose build"
    echo "  docker-compose up -d"
    echo "  docker-compose logs -f"
fi
echo ""

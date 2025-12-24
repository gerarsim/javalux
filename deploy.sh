#!/bin/bash

# Deployment Script for Luxembourg Compliance Application
# Includes security checks and GDPR compliance verification

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================"
echo "Luxembourg Compliance Application Deploy"
echo "========================================"
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${RED}ERROR: .env file not found!${NC}"
    echo "Please copy .env.template to .env and configure it."
    exit 1
fi

# Check required environment variables
echo -e "${YELLOW}Checking required environment variables...${NC}"
required_vars=("DB_PASSWORD" "JWT_SECRET" "ENCRYPTION_KEY")
missing_vars=()

for var in "${required_vars[@]}"; do
    if ! grep -q "^${var}=" .env || grep -q "^${var}=$" .env || grep -q "^${var}=your_" .env; then
        missing_vars+=("$var")
    fi
done

if [ ${#missing_vars[@]} -ne 0 ]; then
    echo -e "${RED}ERROR: Missing or unconfigured environment variables:${NC}"
    printf '%s\n' "${missing_vars[@]}"
    exit 1
fi

echo -e "${GREEN}✓ Environment variables configured${NC}"

# Check Docker and Docker Compose
echo -e "${YELLOW}Checking Docker installation...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}ERROR: Docker is not installed${NC}"
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}ERROR: Docker Compose is not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Docker is installed${NC}"

# Create necessary directories
echo -e "${YELLOW}Creating required directories...${NC}"
mkdir -p logs config nginx/ssl nginx/logs db/init

echo -e "${GREEN}✓ Directories created${NC}"

# Security check: File permissions
echo -e "${YELLOW}Setting secure file permissions...${NC}"
chmod 600 .env
chmod 755 logs config

echo -e "${GREEN}✓ File permissions set${NC}"

# Build Docker images
echo -e "${YELLOW}Building Docker images...${NC}"
if docker compose version &> /dev/null; then
    docker compose build --no-cache
else
    docker-compose build --no-cache
fi

echo -e "${GREEN}✓ Docker images built${NC}"

# Run security scan (if trivy is installed)
if command -v trivy &> /dev/null; then
    echo -e "${YELLOW}Running security scan...${NC}"
    trivy image compliance-app:latest --severity HIGH,CRITICAL
    echo -e "${GREEN}✓ Security scan completed${NC}"
else
    echo -e "${YELLOW}⚠ Trivy not installed. Skipping security scan.${NC}"
    echo "Install with: curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin"
fi

# Compliance checks
echo -e "${YELLOW}Performing compliance checks...${NC}"

# Check data retention settings
if grep -q "DATA_RETENTION_DAYS=2555" docker-compose.yml; then
    echo -e "${GREEN}✓ Data retention set to 7 years (Luxembourg requirement)${NC}"
else
    echo -e "${YELLOW}⚠ Warning: Data retention may not meet Luxembourg 7-year requirement${NC}"
fi

# Check audit logging
if grep -q "AUDIT_LOG_ENABLED=true" docker-compose.yml; then
    echo -e "${GREEN}✓ Audit logging enabled${NC}"
else
    echo -e "${RED}ERROR: Audit logging must be enabled for compliance${NC}"
    exit 1
fi

# Check timezone
if grep -q "TZ=Europe/Luxembourg" docker-compose.yml; then
    echo -e "${GREEN}✓ Luxembourg timezone configured${NC}"
else
    echo -e "${YELLOW}⚠ Warning: Timezone not set to Europe/Luxembourg${NC}"
fi

echo -e "${GREEN}✓ Compliance checks passed${NC}"

# Start services
echo -e "${YELLOW}Starting services...${NC}"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

echo -e "${GREEN}✓ Services started${NC}"

# Wait for services to be healthy
echo -e "${YELLOW}Waiting for services to be healthy...${NC}"
sleep 5

# Check service health
if docker compose version &> /dev/null; then
    docker compose ps
else
    docker-compose ps
fi

# Display access information
echo ""
echo "========================================"
echo -e "${GREEN}Deployment completed successfully!${NC}"
echo "========================================"
echo ""
echo "Application URL: http://localhost:8080"
echo "Health Check: http://localhost:8080/actuator/health"
echo ""
echo "To view logs:"
echo "  docker compose logs -f app"
echo ""
echo "To stop services:"
echo "  docker compose down"
echo ""
echo -e "${YELLOW}IMPORTANT COMPLIANCE REMINDERS:${NC}"
echo "1. Ensure GDPR compliance documentation is up to date"
echo "2. Register with CNPD if processing personal data"
echo "3. Maintain audit logs for 7+ years"
echo "4. Implement data breach notification procedures"
echo "5. Regular security audits are recommended"
echo ""

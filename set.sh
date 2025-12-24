#!/bin/bash

# migrate-to-maven-standard.sh
# Migrates your project to standard Maven structure
# Run this script from the project root directory

set -e

echo "============================================"
echo "Maven Standard Structure Migration Script"
echo "============================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Confirm before proceeding
read -p "This will restructure your project. Create a backup first! Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

echo -e "${YELLOW}Step 1: Creating standard Maven directory structure...${NC}"
mkdir -p src/main/java/lu/yourcompany/compliance
mkdir -p src/main/resources
mkdir -p src/main/resources/db/migration
mkdir -p src/main/resources/templates/email
mkdir -p src/test/java/lu/yourcompany/compliance
mkdir -p src/test/resources

echo -e "${GREEN}✓ Directories created${NC}"

echo -e "${YELLOW}Step 2: Moving application.yml to resources...${NC}"
if [ -f "application.yml" ]; then
    mv application.yml src/main/resources/
    echo -e "${GREEN}✓ application.yml moved${NC}"
else
    echo -e "${YELLOW}⚠ application.yml not found at root${NC}"
fi

echo -e "${YELLOW}Step 3: Checking backend/ directory...${NC}"
if [ -d "backend" ]; then
    echo "Contents of backend/:"
    ls -la backend/
    echo ""
    read -p "Move backend/ contents to src/main/java/? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ -d "backend/src/main/java" ]; then
            # Backend has Maven structure
            mv backend/src/main/java/* src/main/java/lu/yourcompany/compliance/ 2>/dev/null || true
            mv backend/src/main/resources/* src/main/resources/ 2>/dev/null || true
            mv backend/src/test/* src/test/ 2>/dev/null || true
        elif [ -d "backend/java" ]; then
            # Backend has java/ folder
            mv backend/java/* src/main/java/lu/yourcompany/compliance/ 2>/dev/null || true
        else
            # Unknown structure - manual intervention needed
            echo -e "${YELLOW}⚠ Unknown backend structure. Please move files manually.${NC}"
            echo "Expected: backend/src/main/java or backend/java"
        fi
        echo -e "${GREEN}✓ Backend files moved${NC}"
    fi
else
    echo -e "${YELLOW}⚠ backend/ directory not found${NC}"
fi

echo -e "${YELLOW}Step 4: Cleaning up build artifacts...${NC}"
if [ -f "app.jar" ]; then
    rm -f app.jar
    echo -e "${GREEN}✓ Removed app.jar${NC}"
fi

echo -e "${YELLOW}Step 5: Updating .gitignore...${NC}"
if ! grep -q "app.jar" .gitignore 2>/dev/null; then
    cat >> .gitignore << 'GITIGNORE'

# Build artifacts
target/
*.jar
*.war
app.jar

# Logs
logs/
*.log

# Environment
.env
.env.local

# Node
node_modules/
frontend/build/
GITIGNORE
    echo -e "${GREEN}✓ .gitignore updated${NC}"
else
    echo -e "${YELLOW}⚠ .gitignore already has some entries${NC}"
fi

echo -e "${YELLOW}Step 6: Removing duplicate nginx.conf...${NC}"
if [ -f "nginx.conf" ] && [ -f "nginx/nginx.conf" ]; then
    rm nginx.conf
    echo -e "${GREEN}✓ Removed duplicate nginx.conf (kept nginx/nginx.conf)${NC}"
elif [ -f "nginx.conf" ]; then
    echo -e "${YELLOW}⚠ Only root nginx.conf found. Consider moving to nginx/${NC}"
fi

echo -e "${YELLOW}Step 7: Setting up frontend structure...${NC}"
if [ ! -d "frontend/public" ]; then
    mkdir -p frontend/public
    mkdir -p frontend/src/{components,pages,services,hooks,utils}
    echo -e "${GREEN}✓ Frontend directories created${NC}"
else
    echo -e "${YELLOW}⚠ Frontend structure already exists${NC}"
fi

echo -e "${YELLOW}Step 8: Creating README files...${NC}"
cat > db/init/README.md << 'README'
# Database Initialization Scripts

Place your database initialization SQL scripts here.
They will be executed in alphabetical order when the PostgreSQL container starts.

Example:
- `001_create_schema.sql`
- `002_create_tables.sql`
- `003_insert_data.sql`
README

cat > nginx/ssl/README.md << 'README'
# SSL Certificates

Place your SSL certificates here for HTTPS.

Required files:
- `certificate.crt` - SSL certificate
- `private.key` - Private key
- `ca_bundle.crt` - Certificate chain (if applicable)

**IMPORTANT:** These files should NOT be committed to version control!
Add them to .gitignore.
README

echo -e "${GREEN}✓ README files created${NC}"

echo ""
echo "============================================"
echo -e "${GREEN}Migration Complete!${NC}"
echo "============================================"
echo ""
echo "New structure:"
tree -L 3 -I 'node_modules|target|logs' . || ls -la

echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Review the src/ directory structure"
echo "2. Update package names in Java files if needed"
echo "3. Choose the correct Dockerfile:"
echo "   - Use Dockerfile.standard-maven"
echo "4. Test the build: mvn clean package"
echo "5. Update docker-compose.yml dockerfile: to use Dockerfile.standard-maven"
echo "6. Commit changes to git"
echo ""
echo -e "${RED}IMPORTANT:${NC}"
echo "- Review all moved files before committing"
echo "- Update import statements in Java code if package structure changed"
echo "- Test the application thoroughly"
echo ""

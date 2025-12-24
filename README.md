# Luxembourg Compliance Application - Docker Deployment

A production-ready Docker deployment for a Java (Spring Boot) and React application with built-in compliance features for Luxembourg regulatory requirements.

## 🇱🇺 Luxembourg Compliance Features

### GDPR Compliance
- ✅ Data retention policies (7 years minimum)
- ✅ Audit logging for all data access
- ✅ Encryption at rest and in transit
- ✅ Right to be forgotten support
- ✅ Data breach notification mechanisms
- ✅ Cookie consent management
- ✅ Privacy by design architecture

### Luxembourg Legal Requirements
- ✅ CNPD (Commission Nationale pour la Protection des Données) registration support
- ✅ CSSF compliance ready (for financial sector)
- ✅ 7-year data retention for legal documents
- ✅ 10-year retention for financial records
- ✅ Luxembourg timezone (Europe/Luxembourg)
- ✅ Audit trail maintenance

### Security Features
- ✅ Non-root container execution
- ✅ Security headers (HSTS, CSP, X-Frame-Options)
- ✅ Rate limiting
- ✅ SSL/TLS support
- ✅ Container security scanning
- ✅ Resource limits
- ✅ Network isolation

## 📋 Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+ (or docker-compose 1.29+)
- 4GB RAM minimum
- 20GB disk space
- (Optional) Trivy for security scanning

## 🚀 Quick Start

### 1. Clone and Configure

```bash
# Clone the repository
git clone <repository-url>
cd compliance-app

# Copy environment template
cp .env.template .env

# Edit .env with your configuration
nano .env
```

### 2. Configure Environment Variables

Edit `.env` and set at least these required values:

```bash
DB_PASSWORD=your_secure_database_password
JWT_SECRET=your_jwt_secret_key_minimum_32_chars
ENCRYPTION_KEY=your_encryption_key_minimum_32_chars
```

### 3. Deploy

```bash
# Make deploy script executable
chmod +x deploy.sh

# Run deployment
./deploy.sh
```

The script will:
- Validate environment configuration
- Check compliance settings
- Build Docker images
- Run security scans (if Trivy installed)
- Start all services
- Verify health checks

### 4. Access Application

- **Application**: http://localhost:8080
- **Health Check**: http://localhost:8080/actuator/health
- **API Endpoint**: http://localhost:8080/api/

## 📁 Project Structure

```
.
├── Dockerfile                  # Multi-stage build for Java + React
├── docker-compose.yml         # Service orchestration
├── deploy.sh                  # Deployment script
├── .env.template              # Environment configuration template
├── .dockerignore             # Docker build exclusions
├── nginx/
│   ├── nginx.conf            # Nginx configuration with security headers
│   ├── ssl/                  # SSL certificates (production)
│   └── logs/                 # Nginx access/error logs
├── config/                   # Application configuration files
├── logs/                     # Application audit logs
├── db/
│   └── init/                 # Database initialization scripts
├── frontend/                 # React application source
│   ├── package.json
│   ├── public/
│   └── src/
└── backend/                  # Java Spring Boot source
    ├── pom.xml
    └── src/
```

## 🔧 Configuration

### Database Configuration

PostgreSQL 15 is used for data persistence with:
- Automatic initialization
- Health checks
- Data encryption support
- Luxembourg timezone settings

### Data Retention Policies

Configure retention periods in `.env`:

```bash
# Personal data (GDPR requirement)
PERSONAL_DATA_RETENTION_DAYS=2555  # 7 years

# Financial/transaction data
TRANSACTION_DATA_RETENTION_DAYS=3650  # 10 years

# Audit logs
AUDIT_LOG_RETENTION_DAYS=2555  # 7 years minimum
```

### SSL/TLS Configuration (Production)

1. Obtain SSL certificates for your domain
2. Place certificates in `nginx/ssl/`:
   - `certificate.crt` - SSL certificate
   - `private.key` - Private key
3. Update `nginx/nginx.conf`:
   - Uncomment SSL configuration lines
   - Update `server_name` with your domain
4. Restart services: `docker compose restart nginx`

## 🛠️ Management Commands

### View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f app
docker compose logs -f db
docker compose logs -f nginx

# Application audit logs
tail -f logs/audit.log
```

### Database Management

```bash
# Access database
docker compose exec db psql -U appuser -d compliancedb

# Backup database
docker compose exec db pg_dump -U appuser compliancedb > backup.sql

# Restore database
docker compose exec -T db psql -U appuser -d compliancedb < backup.sql
```

### Service Management

```bash
# Stop services
docker compose down

# Stop and remove volumes
docker compose down -v

# Restart specific service
docker compose restart app

# Rebuild and restart
docker compose up -d --build
```

### Health Checks

```bash
# Check service status
docker compose ps

# Application health
curl http://localhost:8080/actuator/health

# Database health
docker compose exec db pg_isready -U appuser
```

## 🔒 Security Best Practices

### 1. Secrets Management
- Never commit `.env` file
- Use strong passwords (16+ characters)
- Rotate secrets regularly
- Consider using Docker secrets or external secret management

### 2. Network Security
- Use internal Docker networks
- Don't expose database port externally
- Implement firewall rules
- Use VPN for administrative access

### 3. Container Security
- Run containers as non-root user ✅
- Enable security options (no-new-privileges) ✅
- Regular security scanning with Trivy
- Keep base images updated

### 4. Monitoring & Auditing
- Enable audit logging ✅
- Monitor access logs
- Set up alerts for suspicious activity
- Regular compliance audits

## 📊 Compliance Checklist

### Before Production Deployment

- [ ] SSL/TLS certificates configured
- [ ] Strong passwords for all services
- [ ] CNPD registration completed (if applicable)
- [ ] Data Protection Officer appointed
- [ ] Privacy policy published
- [ ] Cookie consent implemented
- [ ] Data retention policies documented
- [ ] Backup strategy implemented
- [ ] Incident response plan created
- [ ] Security audit performed
- [ ] Penetration testing completed
- [ ] GDPR documentation prepared
- [ ] Data processing agreements signed
- [ ] Employee training completed

### Luxembourg-Specific

- [ ] Luxembourg timezone configured ✅
- [ ] 7-year data retention for legal docs ✅
- [ ] 10-year retention for financial records
- [ ] CNPD notification for data breaches
- [ ] Luxembourg hosting provider (if required)
- [ ] Compliance with Luxembourg labor law (for HR data)
- [ ] VAT compliance (if applicable)

## 🆘 Troubleshooting

### Services won't start

```bash
# Check logs
docker compose logs

# Verify .env configuration
cat .env

# Check port availability
netstat -tuln | grep -E ':(80|443|8080|5432)'
```

### Database connection errors

```bash
# Verify database is healthy
docker compose ps db

# Check database logs
docker compose logs db

# Verify credentials in .env
```

### Permission errors

```bash
# Fix log directory permissions
chmod 755 logs config

# Fix .env permissions
chmod 600 .env
```

## 📝 License & Legal

This deployment configuration is provided as-is. Ensure you:
- Comply with all Luxembourg and EU regulations
- Consult with legal counsel for compliance requirements
- Register with CNPD for personal data processing
- Maintain proper documentation and audit trails

## 🤝 Support

For compliance questions:
- CNPD: https://cnpd.public.lu
- CSSF: https://www.cssf.lu (for financial sector)

For technical support:
- Review logs in `./logs` directory
- Check health endpoints
- Consult Docker documentation

## 🔄 Updates & Maintenance

Regular maintenance schedule:
- Weekly: Review logs and alerts
- Monthly: Security updates for base images
- Quarterly: Compliance audit
- Annually: Full security assessment

Update base images:
```bash
docker compose pull
docker compose up -d --build
```

---

**Important**: This configuration provides a foundation for Luxembourg compliance but does not guarantee legal compliance. Always consult with legal and compliance experts for your specific use case.

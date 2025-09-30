# Integration with Real Services

This guide will help you replace mock services with your actual microservices.

## Step 1: Prepare Your Services

Make sure each of your services:

1. **Has a Dockerfile** or can be run in Docker
2. **Listens on a specific port** (e.g., 3001, 3002, 3003)
3. **Handles basic HTTP requests**
4. **Has a health check endpoint** (recommended)

## Step 2: Update docker-compose.yml

Replace mock services in `docker-compose.yml`:

### Example for auth-service

```yaml
auth-service:
  build: ../auth-service # or use a ready-made image
  container_name: family-finance-auth
  environment:
    - NODE_ENV=development
    - PORT=3001
    - DATABASE_URL=${DATABASE_URL}
  expose:
    - '3001'
  networks:
    - family-finance-network
  volumes:
    - ../auth-service:/app # for development
  depends_on:
    - database # if you have a database
```

### Example for Node.js service

```yaml
account-service:
  build: ../account-service
  container_name: family-finance-account
  environment:
    - NODE_ENV=development
    - PORT=3002
    - AUTH_SERVICE_URL=http://auth-service:3001
  expose:
    - '3002'
  networks:
    - family-finance-network
  volumes:
    - ../account-service:/app
    - /app/node_modules # anonymous volume for node_modules
```

## Step 3: Update NGINX Configuration

In `conf.d/default.conf`, update upstream servers:

```nginx
# Update ports if they differ
upstream auth_service {
    server auth-service:3001;
    keepalive 32;
}

upstream account_service {
    server account-service:3002;
    keepalive 32;
}

upstream transaction_service {
    server transaction-service:3003;
    keepalive 32;
}
```

## Step 4: Add a Database

```yaml
services:
  # ... your services

  # PostgreSQL Database
  database:
    image: postgres:15-alpine
    container_name: family-finance-db
    environment:
      POSTGRES_DB: family_finance
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql # optional
    networks:
      - family-finance-network
    ports:
      - '5432:5432' # for external access (development)

  # Or MongoDB
  mongodb:
    image: mongo:7
    container_name: family-finance-mongo
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: password
    volumes:
      - mongodb_data:/data/db
    networks:
      - family-finance-network
    ports:
      - '27017:27017'

volumes:
  postgres_data:
  mongodb_data:
```

## Step 5: Health Checks

Add health checks for monitoring:

```yaml
auth-service:
  # ... other configuration
  healthcheck:
    test: ['CMD', 'curl', '-f', 'http://localhost:3001/health']
    interval: 30s
    timeout: 10s
    retries: 3
    start_period: 40s
```

Update NGINX configuration for health checks:

```nginx
# In conf.d/default.conf add
location /api/health {
    access_log off;

    # Check all services
    location /api/health/auth {
        proxy_pass http://auth_service/health;
    }

    location /api/health/accounts {
        proxy_pass http://account_service/health;
    }

    location /api/health/transactions {
        proxy_pass http://transaction_service/health;
    }
}
```

## Step 6: Environment Variables

Create a `.env` file:

```env
# Database
DATABASE_URL=postgresql://postgres:password@database:5432/family_finance
MONGO_URL=mongodb://admin:password@mongodb:27017/family_finance

# Services
AUTH_SERVICE_PORT=3001
ACCOUNT_SERVICE_PORT=3002
TRANSACTION_SERVICE_PORT=3003

# Security
JWT_SECRET=your-super-secret-key
BCRYPT_ROUNDS=12

# Development
NODE_ENV=development
LOG_LEVEL=debug
```

## Step 7: Launch

1. **Stop current mock services:**

```bash
make down
# or
docker-compose down
```

2. **Update configuration** according to the steps above

3. **Rebuild and launch:**

```bash
make build
# or
docker-compose up -d --build
```

4. **Check logs:**

```bash
make logs
# or
docker-compose logs -f
```

5. **Test:**

```bash
./test-gateway.sh
```

## Step 8: Debugging

### Common Issues:

1. **502 Bad Gateway** - service is not running or unavailable

   ```bash
   docker-compose ps
   docker-compose logs [service-name]
   ```

2. **Ports already in use**

   ```bash
   docker-compose down
   docker ps -a
   ```

3. **Database issues**

   ```bash
   docker-compose exec database psql -U postgres -d family_finance
   ```

4. **Network issues**
   ```bash
   docker network ls
   docker network inspect api-gateway_family-finance-network
   ```

## Step 9: Production Readiness

For production, add:

1. **SSL certificates**
2. **Monitoring (Prometheus + Grafana)**
3. **Logging (ELK Stack)**
4. **Secrets management**
5. **Health checks and alerts**
6. **Backup strategy**

## Example API Routes

After integration, your API will be available at:

```
# Authentication
POST   /api/auth/login
POST   /api/auth/signup
POST   /api/auth/logout

```

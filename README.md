# Family Finance API Gateway

NGINX-based API Gateway for the Family Finance application, routing requests between microservices.

## Structure

```
api-gateway/
├── docker-compose.yml    # Docker Compose configuration
├── nginx.conf            # Main NGINX configuration
├── conf.d/               # Additional configurations
│   └── default.conf      # Main API routes
├── ssl/                  # SSL certificates (create if needed)
└── README.md             # This documentation
```

## API Routing

The gateway is configured for the following routes:

- `GET /health` - gateway health check
- `GET /` - API Gateway information
- `/api/auth/*` - authentication service routes
- `/api/accounts/*` - accounts service routes
- `/api/transactions/*` - transactions service routes

## Running

### Local Development

1. Start all services:

```bash
docker-compose up -d
```

2. Check status:

```bash
curl http://localhost/health
```

3. Check API Gateway:

```bash
curl http://localhost/
```

### Stopping Services

```bash
docker-compose down
```

## Managing Individual Services

The gateway is designed for independent operation of microservices. You can manage each service separately.

### Using Makefile Commands

```bash
# Stop individual services
make stop-auth           # Stop authentication service
make stop-accounts       # Stop accounts service
make stop-transactions   # Stop transactions service

# Start individual services
make start-auth          # Start authentication service
make start-accounts      # Start accounts service
make start-transactions  # Start transactions service

# Restart individual services
make restart-auth        # Restart authentication service
make restart-accounts    # Restart accounts service
make restart-transactions # Restart transactions service

# Check status of all services
make status              # Show status of all services
```

### Using Docker Compose Commands

```bash
# Stop a specific service
docker-compose stop auth-service
docker-compose stop account-service
docker-compose stop transaction-service

# Start a specific service
docker-compose up -d auth-service
docker-compose up -d account-service
docker-compose up -d transaction-service

# Restart a specific service
docker-compose restart auth-service

# Completely remove a service container
docker-compose rm -s -f auth-service
```

### What Happens When Services Are Stopped

#### ✅ Continues to work:

- **NGINX Gateway** — always available regardless of service status
- **Other services** — not affected when one is stopped
- **Main page** (`GET /`) — always available
- **Health check** (`GET /health`) — always works
- **CORS and static resources** — continue to function

#### ❌ Stops working:

- **Only API endpoints of the stopped service** return `502 Bad Gateway`

#### Examples:

**When auth-service is stopped:**

```bash
make stop-auth
```

- ❌ `/api/auth/*` → 502 Bad Gateway
- ✅ `/api/accounts/*` → works
- ✅ `/api/transactions/*` → works
- ✅ `/health` → works

**When account-service is stopped:**

```bash
make stop-accounts
```

- ✅ `/api/auth/*` → works
- ❌ `/api/accounts/*` → 502 Bad Gateway
- ✅ `/api/transactions/*` → works
- ✅ `/health` → works

### Service Status Monitoring

```bash
# Quick check of all services
make status

# Detailed container status
docker-compose ps

# Check specific endpoints
curl http://localhost/api/auth/health
curl http://localhost/api/accounts/
curl http://localhost/api/transactions/

# Check logs of a specific service
docker-compose logs -f auth-service
docker-compose logs -f account-service
docker-compose logs -f transaction-service
```

### Development Patterns

**Developing a single service:**

```bash
# Stop all except the needed one
make stop-accounts
make stop-transactions
# Work only with auth-service
```

**Debugging issues:**

```bash
# Restart problematic service
make restart-auth

# View logs
docker-compose logs -f auth-service

# Check network
docker network inspect api-gateway_family-finance-network
```

**Gradual deployment:**

```bash
# Start services one by one
make start-auth
# Check functionality
make start-accounts
# Check functionality
make start-transactions
```

## CORS Configuration

The gateway is set to work with any domain in development mode. For production, it is recommended to:

1. Change `Access-Control-Allow-Origin *` to your frontend domain
2. Set up SSL certificates
3. Add additional security headers

## Monitoring and Logs

View logs:

```bash
# All logs
docker-compose logs -f

# Only gateway logs
docker-compose logs -f nginx-gateway
```

## Rate Limiting

The following limits are set:

- API endpoints: 10 requests per second
- Authentication endpoints: 5 requests per second

## SSL/HTTPS (for production)

To enable HTTPS:

1. Create the `ssl/` directory and place certificates there
2. Update configuration to add SSL block
3. Redirect HTTP to HTTPS

## Replacing Mock Services

Mock services are configured in `docker-compose.yml` for testing. Replace them with your real services:

```yaml
auth-service:
  build: ../auth-service
  # ... your configuration
```

## Environment Variables

You can create a `.env` file for configuration:

```env
# Ports
HTTP_PORT=80
HTTPS_PORT=443

# Rate limiting
API_RATE_LIMIT=10r/s
AUTH_RATE_LIMIT=5r/s

# Upstream servers
AUTH_SERVICE_URL=auth-service:3001
ACCOUNT_SERVICE_URL=account-service:3002
TRANSACTION_SERVICE_URL=transaction-service:3003
```

## Troubleshooting

### Issues connecting to upstream servers

1. Check that services are running:

```bash
docker-compose ps
```

2. Check network:

```bash
docker network ls
docker network inspect api-gateway_family-finance-network
```

3. Check logs of a specific service:

```bash
docker-compose logs [service-name]
```

### 502 Bad Gateway

Usually means the upstream server is unavailable:

- Check service status
- Make sure configuration ports match service ports

### CORS Issues

Check response headers:

```bash
curl -I -X OPTIONS http://localhost/api/auth/
```

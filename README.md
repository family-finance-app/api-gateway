# Family Finance API Gateway

NGINX-based API Gateway for the Family Finance application, routing requests to the backend service.

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

The gateway is configured to route all `/api/*` requests to the family-finance-backend service:

- `GET /health` - gateway health check
- `/api/*` - all API routes proxied to backend service

## Running

### Prerequisites

1. Create shared Docker network (run this once):

```bash
docker network create family-finance-network
```

2. Make sure the backend service is running:

```bash
# In the backend directory
cd ../backend
docker-compose up -d
```

### Start API Gateway

```bash
# In the api-gateway directory
docker-compose up -d
```

### Check Status

```bash
# Check gateway health
curl http://localhost/health

# Check proxied API
curl http://localhost/api/health
```

### Stopping Services

```bash
docker-compose down
```

## Development Workflow

### Starting Both Services

1. **Start Backend:**

```bash
cd backend
docker-compose up -d
```

2. **Start API Gateway:**

```bash
cd api-gateway
docker-compose up -d
```

3. **Verify Setup:**

```bash
# Check gateway
curl http://localhost/health

# Check backend through gateway
curl http://localhost/api/health
```

### Stopping Services

```bash
# Stop gateway
cd api-gateway
docker-compose down

# Stop backend
cd backend
docker-compose down
```

## Service Communication

The API Gateway communicates with the backend service through Docker networking:

- **Gateway:** `family-finance-gateway` (port 80/443)
- **Backend:** `family-finance-backend` (port 3000)
- **Network:** `family-finance-network` (external)

## CORS Configuration

The gateway is configured with CORS headers for frontend development:

- **Allowed Origin:** `http://localhost:3000` (frontend)
- **Allowed Methods:** GET, POST, PUT, DELETE, OPTIONS
- **Allowed Headers:** Authorization, Content-Type, Accept

## Rate Limiting

The following limits are configured:

- **API endpoints:** 10 requests per second
- **Authentication endpoints:** 5 requests per second

## Monitoring and Logs

View logs:

```bash
# Gateway logs
docker-compose logs -f

# Backend logs (from backend directory)
cd ../backend
docker-compose logs -f
```

## Troubleshooting

### 502 Bad Gateway

Usually means the backend service is not available:

1. Check backend service status:

```bash
cd ../backend
docker-compose ps
```

2. Check network connectivity:

```bash
docker network inspect family-finance-network
```

3. Verify backend health:

```bash
curl http://localhost:3000/api/health
```

### CORS Issues

Check response headers:

```bash
curl -I -X OPTIONS http://localhost/api/auth/
```
